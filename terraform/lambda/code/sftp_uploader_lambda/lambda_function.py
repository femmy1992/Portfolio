import boto3
import json
import os
import paramiko
import logging

# Initialize logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3_client = boto3.client('s3')

def list_s3_files(s3_bucket_name, s3_prefix):
    """
    List files in an S3 bucket with the specified prefix (directory).
    """
    try:
        logger.info(f"Listing files in S3 bucket: {s3_bucket_name}, under prefix: {s3_prefix}")
        response = s3_client.list_objects_v2(Bucket=s3_bucket_name, Prefix=s3_prefix)
        files = [content['Key'] for content in response.get('Contents', [])]
        logger.info(f"Files found: {files}")
        return files
    except Exception as e:
        logger.error(f"Error listing S3 files: {e}")
        raise e

def sftp_upload_files(sftp_host, sftp_username, private_key_path, s3_bucket_name, sftp_directory, s3_files):
    """
    Upload files from S3 to an SFTP server.
    """
    try:
        # Load the RSA private key
        key = paramiko.RSAKey.from_private_key_file(private_key_path)

        transport = paramiko.Transport((sftp_host, 22))
        transport.connect(username=sftp_username, pkey=key)
        sftp = paramiko.SFTPClient.from_transport(transport)
        
        uploaded_files = []
        files_uploaded_count = 0

        # Process each S3 file
        for s3_key in s3_files:
            if s3_key.endswith('/'):
                continue  # Skip directories

            file_name = os.path.basename(s3_key)
            local_final_file = f'/tmp/{file_name}'

            # Download the file from S3 to the /tmp directory
            try:
                logger.info(f"Downloading {file_name} from S3 bucket {s3_bucket_name} to tmp/...")
                s3_client.download_file(s3_bucket_name, s3_key, local_final_file)
            except Exception as e:
                logger.error(f"Error downloading {file_name} from S3. Skipping file. Error: {e}")
                continue

            # Construct the remote path on the SFTP server without duplication
            sftp_path = f"{sftp_directory}/{file_name}".replace('//', '/')

            # Upload the file to the SFTP server
            try:
                logger.info(f"Uploading {file_name} to SFTP server at {sftp_path}...")
                sftp.put(local_final_file, sftp_path)
                logger.info(f"Successfully uploaded {file_name} to {sftp_path}")
                uploaded_files.append(sftp_path)
                files_uploaded_count += 1
            except Exception as e:
                logger.error(f"Error uploading {file_name} to SFTP. Skipping file. Error: {e}")
                continue

            # Clean up local file after upload
            try:
                os.remove(local_final_file)
            except Exception as e:
                logger.error(f"Error cleaning up {local_final_file}: {e}")

        sftp.close()
        transport.close()

        return uploaded_files, files_uploaded_count
    except Exception as e:
        logger.error(f"An error occurred during SFTP operations: {e}")
        raise e

def lambda_handler(event, context):
    """
    AWS Lambda handler function.
    """
    try:
        # Retrieve runtime parameters from the Step Function input
        sftp_host = event.get('SFTP_HOST')
        sftp_username = event.get('SFTP_USERNAME')
        sftp_directory = event.get('SFTP_DIRECTORY_UPLOADER')  
        s3_bucket_name = event.get('S3_BUCKET_NAME')
        s3_prefix = event.get('S3_PREFIX')  
        private_key_content = event.get('SFTP_PRIVATE_KEY')
        
        # Debugging 
        logger.info(f"Received private key content: {private_key_content[:100]}...")
        logger.info(f"Received sftp host: {sftp_host}...")
        logger.info(f"Received sftp username: {sftp_username}...")
        logger.info(f"Received sftp directory: {sftp_directory}...")
        logger.info(f"Received s3 bucket: {s3_bucket_name}...")
        logger.info(f"Received s3 prefix: {s3_prefix}...")

        # Save the private key to /tmp directory
        private_key_path = '/tmp/sftp_key.pem'
        if os.path.exists(private_key_path):
            os.remove(private_key_path)

        with open(private_key_path, 'w') as key_file:
            key_file.write(private_key_content)
        os.chmod(private_key_path, 0o400)  

        # List all files under the specified S3 prefix
        s3_files = list_s3_files(s3_bucket_name, s3_prefix)

        if not s3_files:
            return {
                'statusCode': 200,
                'body': json.dumps('No files found in the specified S3 prefix.')
            }

        # Start the upload process
        uploaded_files, files_uploaded_count = sftp_upload_files(sftp_host, sftp_username, private_key_path, s3_bucket_name, sftp_directory, s3_files)

        if uploaded_files:
            return {
                'statusCode': 200,
                'body': json.dumps(f'Successfully uploaded {files_uploaded_count} files to SFTP.')
            }
        else:
            return {
                'statusCode': 200,
                'body': json.dumps('No files uploaded to SFTP.')
            }
    except Exception as e:
        logger.error(f"An error occurred: {e}")
        raise e
