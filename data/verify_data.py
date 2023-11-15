import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('users')

response = table.scan()

for item in response['Items']:
    print(item)