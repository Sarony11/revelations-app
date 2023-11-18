import json
import boto3
from botocore.exceptions import ClientError

# Inicializar un cliente de DynamoDB
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    # Obtener el UserID del path de la solicitud
    user_id = event['pathParameters']['UserID']

    # Referencia a la tabla de DynamoDB
    table = dynamodb.Table('users')

    # Intentar borrar el usuario de DynamoDB
    try:
        response = table.delete_item(
            Key={'UserID': user_id}
        )
        return {
            'statusCode': 200,
            'body': json.dumps(f"User {user_id} deleted successfully")
        }
    except ClientError as e:
        print(e.response['Error']['Message'])
        return {
            'statusCode': 500,
            'body': json.dumps("Error deleting the user")
        }

#lambda_handler({'pathParameters': {'UserID': 'user1'}}, None)