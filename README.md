DESCRIPTION
The objective of this project is to develop a dynamic website capable of performing CRUD operations using API Gateway, leveraging an S3 bucket.

PREREQUISITES
An active AWS account.

STEPS
1. Set up a DynamoDB table with the partition key as "ID".
2. Configure a Lambda function with Python 3.10 runtime. Utilize the provided Python script "lambda_function.py" to insert items into the DynamoDB table.
3. Establish an API Gateway with a POST method, integrating it with the Lambda function from step 2.
4. Create an S3 bucket and upload the JavaScript file required for the static website.
