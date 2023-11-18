import boto3
import sys

if len(sys.argv) < 2:
    print("Use: python script.py <table_name>")
    sys.exit(1)

table_name = sys.argv[1]

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(table_name)

response = table.scan()

for item in response['Items']:
    print(item)
