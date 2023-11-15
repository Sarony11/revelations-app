import boto3
import json
import os

def check_if_table_has_items(dynamodb_resource, table_name):
    """
    Check if the DynamoDB table has any items.
    """
    table = dynamodb_resource.Table(table_name)
    response = table.scan(Select='COUNT')
    return response['Count'] > 0

def clean_table(dynamodb_resource, table_name):
    """
    Delete all items from a DynamoDB table.
    """
    table = dynamodb_resource.Table(table_name)

    # Scan the table
    print(f"Scanning table {table_name} for items...")
    response = table.scan()
    items = response['Items']

    # Delete each item
    print(f"Deleting items from table {table_name}...")
    for item in items:
        # Extract the primary key
        key = {key_description['AttributeName']: item[key_description['AttributeName']] for key_description in table.key_schema}
        table.delete_item(Key=key)

    print(f"All items have been deleted from table {table_name}.")


def ingest_data(dynamodb, table_name, data_path, key_ID):
    table = dynamodb.Table(table_name)

    with open(data_path) as json_file:
        collection = json.load(json_file)
        for item in collection:
            response = table.put_item(Item=item)
            print(f"User inserted: {item[key_ID]}, response: {response}")
        
        print(f"-------All {table_name} data has being inserted.-------")

def main():
    script_dir = os.path.dirname(__file__)  # Directory where the script is located
    
    #### INSERT USERS DATA ####
    # Init DynamoDB client
    dynamodb_resource = boto3.resource('dynamodb')

    # Specify the table variables
    table_name = "users"
    data_path = os.path.join(script_dir, "users_collection.json")
    data_path = os.path.abspath(data_path)
    key_ID = "UserID"

    # Verify if the table exists, then delete it
    if check_if_table_has_items(dynamodb_resource, table_name):
        clean_table(dynamodb_resource, table_name)
    else: print(f"---- No items on table {table_name}. -----")

    # Ingest data
    ingest_data(dynamodb_resource, table_name, data_path, key_ID)

    ### INSERT PACKS DATA ###
    # Init DynamoDB client

    # Specify the table variables
    table_name = "question_packs"
    data_path = os.path.join(script_dir, "questions_collection.json")
    data_path = os.path.abspath(data_path)
    key_ID = "PackID"

    # Verify if the table exists, then delete it
    if check_if_table_has_items(dynamodb_resource, table_name):
        clean_table(dynamodb_resource, table_name)

    # Ingest data
    ingest_data(dynamodb_resource, table_name, data_path, key_ID)

if __name__ == "__main__":
    main()