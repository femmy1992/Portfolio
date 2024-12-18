import boto3
import json
import os
import paramiko  
from datetime import datetime
import logging

# Initialize logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3_client = boto3.client('s3')

def sftp_pull_files(sftp_host, sftp_username, private_key_path, s3_bucket_name, sftp_directory, receiver_bucket_prefix):
    """
    Pull files from an SFTP server, upload them to S3, and remove them from the SFTP server.
    """
    try:
        # Establish SFTP connection using private key
        logger.info("Connecting to SFTP server...")

        # Load the RSA private key
        key = paramiko.RSAKey.from_private_key_file(private_key_path)

        transport = paramiko.Transport((sftp_host, 22))
        transport.connect(username=sftp_username, pkey=key)
        sftp = paramiko.SFTPClient.from_transport(transport)

        # Change to the correct directory on the SFTP server
        logger.info(f"Changing directory to {sftp_directory}...")
        sftp.chdir(sftp_directory)

        # List files in the target directory
        logger.info("Fetching files from SFTP server...")
        files = sftp.listdir()
        logger.info(f"Files found: {files}")
        copied_files = []
        files_copied_count = 0

        # Process each file
        for file in files:
            local_path = f'/tmp/{file}'
            sftp.get(file, local_path)  # Download the file

            # Upload to S3, using the receiver bucket prefix (e.g., /request)
            date_folder = datetime.now().strftime('%Y-%m-%d')
            s3_key = f'{receiver_bucket_prefix}/{date_folder}/{file}'
            s3_client.upload_file(local_path, s3_bucket_name, s3_key)
            logger.info(f'Uploaded {file} to S3 bucket under {receiver_bucket_prefix}/{date_folder}.')
            files_copied_count += 1

            # Remove file from SFTP server after copying
            sftp.remove(file)
            copied_files.append(file)

        sftp.close()
        transport.close()
        logger.info(f"SFTP Pull and Upload to S3 completed. {files_copied_count} files copied.")
        return copied_files, files_copied_count
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
        sftp_directory = event.get('SFTP_DIRECTORY_RECEIVER')
        s3_bucket_name = event.get('S3_BUCKET_NAME')
        private_key_content = event.get('SFTP_PRIVATE_KEY')
        receiver_bucket_prefix = event.get('RECEIVER_BUCKET_PREFIX')  

        # Debugging 
        logger.info(f"Received private key content: {private_key_content[:100]}...")
        logger.info(f"Received sftp host: {sftp_host}...")
        logger.info(f"Received sftp username: {sftp_username}...")
        logger.info(f"Received sftp directory: {sftp_directory}...")
        logger.info(f"Received s3 bucket: {s3_bucket_name}...")
        logger.info(f"Received s3 prefix: {receiver_bucket_prefix}...")
        
        # Save the private key to /tmp directory
        private_key_path = '/tmp/sftp_key.pem'
        
        # If the file exists, remove it before writing the new key
        if os.path.exists(private_key_path):
            os.remove(private_key_path)
        
        # Write the private key content to a file
        with open(private_key_path, 'w') as key_file:
            key_file.write(private_key_content)
        os.chmod(private_key_path, 0o400)  # Set appropriate permissions on the key file

        logger.info("Starting SFTP Pull and S3 Upload Process...")
        copied_files, files_copied_count = sftp_pull_files(sftp_host, sftp_username, private_key_path, s3_bucket_name, sftp_directory, receiver_bucket_prefix)
        
        date_folder = datetime.now().strftime('%Y-%m-%d')

        if copied_files:
            logger.info(f"Successfully copied {files_copied_count} files from SFTP and removed them. Files: {copied_files}")
        else:
            logger.info("No files found on SFTP to process.")
    except Exception as e:
        logger.error(f"An error occurred: {e}")
        raise e

    return {
        'statusCode': 200,
        'body': json.dumps(f'SFTP Pull and S3 Upload Process Completed. {files_copied_count} files copied to folder {receiver_bucket_prefix}/{date_folder}.')
    }
