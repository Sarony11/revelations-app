import json
import boto3
from botocore.exceptions import ClientError

# Init DynamoDB resource


def lambda_handler(event, context):
    
    dynamodb = boto3.resource('dynamodb')
    # Get event UserID
    user_id = event['pathParameters']['UserID']

    # Set DynamoDB table name
    table = dynamodb.Table('users')

    # Intentar obtener el usuario de DynamoDB
    try:
        response = table.get_item(Key={'UserID': user_id})
    except ClientError as e:
        print(e.response['Error']['Message'])
        return {
            'statusCode': 500,
            'body': json.dumps("Error getting user")
        }
    else:
        print(response)
        item = response.get('Item', None)
        if not item:
            # User not found, return 404
            return {
                'statusCode': 404,
                'body': json.dumps("User not found")
            }
        else:
            # User found, return user data
            return {
                'statusCode': 200,
                'body': json.dumps(item)
            }

lambda_handler({'pathParameters': {'UserID': 'user1'}}, None)