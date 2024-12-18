import boto3
import json
import logging
import os
from office365.sharepoint.client_context import ClientContext
from office365.runtime.auth.user_credential import UserCredential
from office365.runtime.client_request_exception import ClientRequestException

# Initialize logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3_client = boto3.client('s3')

def create_folder_sharepoint(sharepoint_doc, folder_name, sharepoint_user, sharepoint_pass, sharepoint_site_url):
    """Create the folder in SharePoint if it doesn't exist"""
    try:
        logger.info(f'Creating SharePoint folder {folder_name}...')
        ctx = ClientContext(sharepoint_site_url).with_credentials(UserCredential(sharepoint_user, sharepoint_pass))
        
        folder_url = f"{sharepoint_doc}/{folder_name}".strip('/')
        parent_folder = ctx.web.ensure_folder_path(folder_url)
        ctx.execute_query()

        logger.info(f"Folder {folder_url} created or already exists.")
        return folder_url
    except ClientRequestException as e:
        logger.error(f"Error creating SharePoint folder: {e.message}")
        raise

def upload_file_to_sharepoint(file_path, file_name, folder_name, sharepoint_user, sharepoint_pass, sharepoint_site_url):
    """Upload file to the specified SharePoint folder"""
    try:
        ctx = ClientContext(sharepoint_site_url).with_credentials(UserCredential(sharepoint_user, sharepoint_pass))
        
        logger.info(f"Uploading to SharePoint folder: {folder_name}")
        target_folder = ctx.web.get_folder_by_server_relative_url(folder_name)

        with open(file_path, 'rb') as file_content:
            target_file = target_folder.upload_file(file_name, file_content.read()).execute_query()

        logger.info(f"Uploaded file to SharePoint at {target_file.serverRelativeUrl}")
    except ClientRequestException as e:
        logger.error(f"Error during SharePoint upload: {e.message}")
        raise

def lambda_handler(event, context):
    # Retrieve environment variables for SharePoint user, site URL, and S3 bucket directory
    sharepoint_user = event.get('SHAREPOINT_USERNAME')
    sharepoint_pass = event.get('SHAREPOINT_PASSWORD')
    sharepoint_site_url = event.get('SHAREPOINT_SITE_URL')
    sharepoint_doc = event.get('SHAREPOINT_DOC')
    sharepoint_subfolder = event.get('SHAREPOINT_SUBFOLDER')
    s3_bucket = event.get('S3_BUCKET')
    s3_prefix = event.get('RECEIVER_BUCKET_PREFIX')

    files_copied_to_sharepoint_count = 0

    # List objects under the S3 prefix 
    s3_objects = s3_client.list_objects_v2(Bucket=s3_bucket, Prefix=s3_prefix)
    
    if 'Contents' not in s3_objects:
        logger.info(f"No files found in S3 bucket {s3_bucket} under prefix {s3_prefix}. Exiting.")
        return {
            'statusCode': 200,
            'body': json.dumps(f'No files found in the specified S3 prefix: {s3_prefix}.')
        }

    # Process each file in the S3 bucket
    for s3_object in s3_objects['Contents']:
        s3_key = s3_object['Key'] 
        
        # Extract folder and file name from S3 key
        folder_name_in_s3 = os.path.dirname(s3_key).split('/')[-1]  
        file_name = os.path.basename(s3_key)  
        file_path = f'/tmp/{file_name}'

        try:
            with open(file_path, 'wb') as f:
                s3_client.download_fileobj(s3_bucket, s3_key, f)
            logger.info(f"Downloaded {file_name} from S3.")
        except Exception as e:
            logger.error(f"Error downloading {file_name} from S3: {e}")
            continue

        # Create a subfolder in SharePoint based on the S3 folder
        sharepoint_folder_path = f"{sharepoint_doc}/{sharepoint_subfolder}/{folder_name_in_s3}"
        full_folder_path = create_folder_sharepoint(sharepoint_doc, f"{sharepoint_subfolder}/{folder_name_in_s3}", sharepoint_user, sharepoint_pass, sharepoint_site_url)

        # Upload file to the created folder in SharePoint
        upload_file_to_sharepoint(file_path, file_name, full_folder_path, sharepoint_user, sharepoint_pass, sharepoint_site_url)
        files_copied_to_sharepoint_count += 1

        # Clean up local file after upload
        os.remove(file_path)
        logger.info(f"Cleaned up {file_path} after upload.")
        
    logger.info(f"S3 to SharePoint sync completed. {files_copied_to_sharepoint_count} files copied to SharePoint.")

    return {
        'statusCode': 200,
        'body': json.dumps('S3 to SharePoint Sync Completed')
    }
