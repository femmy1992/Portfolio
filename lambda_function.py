import boto3 
import json
from time import gmtime, strftime

session = boto3.session.Session(region_name='us-east-1')
dynamodb = session.resource('dynamodb')
table = dynamodb.Table('dev-db')
now = strftime("%a, %d %b %Y %H:%M:%S", gmtime())

# POST Operation
def lambda_handler(event, context):
    print(event)
    response = table.put_item(
        Item={
            **event,
            'Time': now
        }
    )
    print(response)
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }

# # GET Operation
# def lambda_handler(event, context):
    
#     print('event: ', event)
    
#     response = table.get_item(
#         Key = event
#     ) 
    
#     print(response['Item'])
    
#     return {
#         'statusCode': 200,
#         'body': json.dumps(response['Item'])
#     }

# # UPDATE operation
# def lambda_handler(event, context):
#     print('event:', event)
#     update_expression = 'SET '
#     expression_attribute_values = {}

#     for key, value in event.items():
#         if key != 'ID':
#             update_expression += f'{key} = :{key}, '
#             expression_attribute_values[f':{key}'] = value

#     update_expression += 'UpdateTime = :time'
#     expression_attribute_values[':time'] = now

#     response = table.update_item(
#         Key={
#             'ID': event['ID']
#         },
#         UpdateExpression=update_expression,
#         ExpressionAttributeValues=expression_attribute_values
#     )

#     print(response)
#     return {
#         'statusCode': 200,
#         'body': json.dumps(response)
#     }

# # DELETE Operation - multiple items 
# def lambda_handler(event, context):
#     print('event:', event)
#     ids = event.get('IDs', [])
#     responses = []
    
#     for id in ids:
#         response = table.delete_item(
#             Key={
#                 'ID': str(id)
#             }
#         )
#         responses.append(response)
#         print(response)
    
#     return {
#         'statusCode': 200,
#         'body': json.dumps(responses)
#     }
    
# # DELETE Operation - single item 
# def lambda_handler(event, context):
#     print('event:', event)
#     response = table.delete_item(
#         Key={
#             'ID': event['ID']
#         }
#     )
#     print(response)
#     return {
#         'statusCode': 200,
#         'body': json.dumps(response)
#     }