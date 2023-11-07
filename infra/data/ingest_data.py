import boto3
import json

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('users')

with open('./users.json') as json_file:
    users = json.load(json_file)
    for user in users:
        item = {'ID': user['id']}
        item.update(user['data'])
        table.put_item(Item=item)