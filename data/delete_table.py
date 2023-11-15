import boto3

# Create a DynamoDB service client
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')  # replace 'your-region' with your DynamoDB table's region

# Specify the table name
table_name = 'users'  # replace 'your-table-name' with the name of your table

# Get the table resource
table = dynamodb.Table(table_name)

# Delete the table
table.delete()

print(f"Table {table_name} is being deleted.")
