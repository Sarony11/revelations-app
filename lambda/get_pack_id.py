import json
import boto3
from botocore.exceptions import ClientError

# Init DynamoDB resource


def lambda_handler(event, context):
    
    dynamodb = boto3.resource('dynamodb')
    # Get event UserID
    pack_id = event['pathParameters']['PackID']

    # Set DynamoDB table name
    table = dynamodb.Table('question_packs')

    # Intentar obtener el usuario de DynamoDB
    try:
        response = table.get_item(Key={'PackID': pack_id})
    except ClientError as e:
        print(e.response['Error']['Message'])
        return {
            'statusCode': 500,
            'body': json.dumps("Error getting pack")
        }
    else:
        item = response.get('Item', None)
        if not item:
            # Pack not found, return 404
            return {
                'statusCode': 404,
                'body': json.dumps("Pack not found")
            }
        else:
            # Pack found, return pack data
            return {
                'statusCode': 200,
                'body': json.dumps(item)
            }

#lambda_handler({'pathParameters': {'PackID': 'pack1'}}, None)
