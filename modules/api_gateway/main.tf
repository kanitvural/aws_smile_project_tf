resource "aws_api_gateway_rest_api" "this" {
  name        = "smile_api_gateway"
  description = "API Gateway for Lambda functions"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "detection" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "detection"
}

resource "aws_api_gateway_resource" "rekognition" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "rekognition"
}

resource "aws_api_gateway_resource" "records" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "records"
}

resource "aws_api_gateway_resource" "email" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "email"
}


resource "aws_api_gateway_method" "options_detection" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.detection.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "options_rekognition" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.rekognition.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "options_records" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.records.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "options_email" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.email.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "mock_integration_detection" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.detection.id
  http_method = aws_api_gateway_method.options_detection.http_method
  type        = "MOCK"
  integration_http_method = "POST"
}

resource "aws_api_gateway_integration" "mock_integration_rekognition" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.rekognition.id
  http_method = aws_api_gateway_method.options_rekognition.http_method
  type        = "MOCK"
  integration_http_method = "POST"
}

resource "aws_api_gateway_integration" "mock_integration_records" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.records.id
  http_method = aws_api_gateway_method.options_records.http_method
  type        = "MOCK"
  integration_http_method = "POST"
}

resource "aws_api_gateway_integration" "mock_integration_email" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.email.id
  http_method = aws_api_gateway_method.options_email.http_method
  type        = "MOCK"
  integration_http_method = "POST"
}


resource "aws_api_gateway_method" "post_detection" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.detection.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_rekognition" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.rekognition.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_records" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.records.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_email" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.email.id
  http_method   = "POST"
  authorization = "NONE"
}

# GET for dynamodb
resource "aws_api_gateway_method" "get_records" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.records.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_get_records" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.records.id
  http_method             = aws_api_gateway_method.get_records.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_records_arn}/invocations"
}

resource "aws_lambda_permission" "api_gateway_lambda_get_records" {
  statement_id  = "AllowExecutionFromAPIGatewayGetRecords"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_dynamodb"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/GET/records"
}

# GET for dynamodb



resource "aws_api_gateway_integration" "lambda_detection" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.detection.id
  http_method = aws_api_gateway_method.post_detection.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_detection_arn}/invocations"
}

resource "aws_api_gateway_integration" "lambda_rekognition" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.rekognition.id
  http_method = aws_api_gateway_method.post_rekognition.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_rekognition_arn}/invocations"
}

resource "aws_api_gateway_integration" "lambda_records" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.records.id
  http_method = aws_api_gateway_method.post_records.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_records_arn}/invocations"
}

resource "aws_api_gateway_integration" "lambda_email" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.email.id
  http_method = aws_api_gateway_method.post_email.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_email_arn}/invocations"
}



resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = "p"

  depends_on = [
    aws_api_gateway_integration.lambda_detection,
    aws_api_gateway_integration.lambda_rekognition,
    aws_api_gateway_integration.lambda_records,
    aws_api_gateway_integration.lambda_email,
    aws_api_gateway_integration.lambda_get_records,
  ]
}



# permissions

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "api_gateway_lambda_detection" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_detection"
  principal     = "apigateway.amazonaws.com"


  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/*/detection"
}

resource "aws_lambda_permission" "api_gateway_lambda_rekognition" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_rekognition"
  principal     = "apigateway.amazonaws.com"


  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/*/rekognition"
}

resource "aws_lambda_permission" "api_gateway_lambda_records" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_dynamodb"
  principal     = "apigateway.amazonaws.com"


  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/*/records"
}

resource "aws_lambda_permission" "api_gateway_lambda_email" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_email"
  principal     = "apigateway.amazonaws.com"


  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/*/email"
}



