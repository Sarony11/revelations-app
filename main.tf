### Provider configuration
provider "aws" {
  region = "us-east-1"
}

### DynamoDB tables
resource "aws_dynamodb_table" "users" {
  name           = "users"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserID"

  attribute {
    name = "UserID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "question_packs" {
  name           = "question_packs"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "PackID"

  attribute {
    name = "PackID"
    type = "S"
  }
}

### Data ingestion
resource "null_resource" "data_ingestion" {
  # This is a hack to get around the fact that Terraform doesn't support
  # What we do is to ingest data in the different DynamoDB tables.
  provisioner "local-exec" {
    command = <<EOT
      make -f Makefile setup;
      make -f Makefile run;
    EOT
    working_dir = "${path.module}/data"
  }
  depends_on = [
    aws_dynamodb_table.users,
    aws_dynamodb_table.question_packs
  ]
}

#### LAMBDA EXECUTION ROLE #####
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb_access" {
  name = "lambda_dynamodb_access"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "dynamodb:Scan",
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:dynamodb:us-east-1:173776345966:table/users"
      },
    ]
  })
}

##### LAMBDA FUNCTIONS #####
resource "aws_lambda_function" "get_users" {
  function_name = "getUsers"
  handler       = "get_users.lambda_handler"
  runtime       = "python3.8"

  role          = aws_iam_role.lambda_exec_role.arn

  filename         = "${path.module}/lambda/get_users.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/get_users.zip")
}

resource "aws_lambda_function" "get_user_id" {
  function_name = "getUserID"
  handler       = "get_user_id.lambda_handler"
  runtime       = "python3.8"

  role          = aws_iam_role.lambda_exec_role.arn

  filename         = "${path.module}/lambda/get_user_id.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/get_user_id.zip")
}

###### API DEFINITION ######
resource "aws_api_gateway_rest_api" "default" {
  name        = "ReflexionsAPI"
  description = "API for Reflexions game Operations"
}

## API RESOURCES
resource "aws_api_gateway_resource" "get_users" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  path_part   = "users"  # /users path
}

resource "aws_api_gateway_resource" "get_user_id" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  parent_id   = aws_api_gateway_resource.get_users.id
  #parent_id   = aws_api_gateway_resource.get_users.id
  path_part   = "{UserID}"  # /users/{UserID} path
}

## API METHODS
resource "aws_api_gateway_method" "get_users" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.get_users.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_user_id" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.get_user_id.id
  http_method   = "GET"
  authorization = "NONE"
}

## API INTEGRATIONS
resource "aws_api_gateway_integration" "get_users_integration" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.get_users.id
  http_method = aws_api_gateway_method.get_users.http_method

  integration_http_method = "POST"  # AWS uses POST to invoke Lambda functions
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_users.invoke_arn
}

resource "aws_api_gateway_integration" "get_user_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.get_user_id.id
  http_method = aws_api_gateway_method.get_user_id.http_method

  integration_http_method = "POST"  # AWS uses POST to invoke Lambda functions
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_user_id.invoke_arn
}

## API DEPLOYMENT
resource "aws_api_gateway_deployment" "default" {
  depends_on = [
    aws_api_gateway_integration.get_users_integration,
    aws_api_gateway_integration.get_user_id_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.default.id
  stage_name  = "v1"

  # To make changes to be affective, aws_api_gateway_deployment has to be redeploy.
  # This makes the resource to be redeployed everytime.
  triggers = {
    #redeployment = sha256(jsonencode(aws_api_gateway_rest_api.default.body))
    redeployment = "${timestamp()}"
  }
}

## API PERMISSIONS
resource "aws_lambda_permission" "get_users" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_users.function_name
  principal     = "apigateway.amazonaws.com"

  # /stage_name/HTTP_method/resource_path
  source_arn = "${aws_api_gateway_rest_api.default.execution_arn}/v1/GET/users"
}

resource "aws_lambda_permission" "get_user_id" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_id.function_name
  principal     = "apigateway.amazonaws.com"

  # /stage_name/HTTP_method/resource_path
  source_arn = "${aws_api_gateway_rest_api.default.execution_arn}/v1/GET/users/{UserID}"
}

/* ####### ----- TEST API ----- #######
# This lambda is just to test that API-Lambda integration works.
resource "aws_lambda_function" "hello_world" {
  function_name    = "hello_world"
  handler          = "hello_world.lambda_handler"
  runtime          = "python3.8"
  
  role             = aws_iam_role.lambda_exec_role.arn
  
  filename         = "${path.module}/lambda/hello_world.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/hello_world.zip")
}

# Create API resource
resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  path_part   = "helloworld"  # /helloworld path
}

# Create API method
resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integrate API with Lambda Function
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.my_resource.id
  http_method = aws_api_gateway_method.my_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.hello_world.invoke_arn
}

# Assign Permissions to Lambda to be invoked by the API Gateway
resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  # /stage_name/HTTP_method/resource_path
  source_arn = "${aws_api_gateway_rest_api.default.execution_arn}/*//*"
}

# Deploy API
resource "aws_api_gateway_deployment" "my_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.default.id
  stage_name  = "test"
}

output "test_api_endpoint" {
  value = "${aws_api_gateway_deployment.my_deployment.invoke_url}/helloworld"
} */