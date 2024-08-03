variable "lambda_functions" {
  description = "A list of Lambda function configurations"
  type = list(object({
    function_name = string
    handler       = string
    runtime       = string
    timeout       = number
    environment_variables = map(string)
  }))
  default = [
    {
      function_name = "lambda_detection"
      handler       = "lambda_detection.lambda_handler"
      runtime       = "python3.12"
      timeout       = 60
      environment_variables = {}  // Gerekirse çevre değişkenlerini burada belirleyin
    },
    {
      function_name = "lambda_rekognition"
      handler       = "lambda_rekognition.lambda_handler"
      runtime       = "python3.12"
      timeout       = 60
      environment_variables = {}
    },
    {
      function_name = "lambda_dynamodb"
      handler       = "lambda_dynamodb.lambda_handler"
      runtime       = "python3.12"
      timeout       = 60
      environment_variables = {}
    },
    {
      function_name = "lambda_email"
      handler       = "lambda_email.lambda_handler"
      runtime       = "python3.12"
      timeout       = 60
      environment_variables = {}
    }
  ]
}



variable "windows_paths" {
  description = "Paths for Windows OS"
  type = map(object({
    source_file = string
    source_zip  = string
  }))
  default = {
    lambda_detection = {
      source_file = "modules\\lambda\\code\\lambda_detection\\lambda_detection.py"
      source_zip  = "modules\\lambda\\code\\lambda_detection.zip"
    }
    lambda_rekognition = {
      source_file = "modules\\lambda\\code\\lambda_rekognition\\lambda_rekognition.py"
      source_zip  = "modules\\lambda\\code\\lambda_rekognition.zip"
    }
    lambda_dynamodb = {
      source_file = "modules\\lambda\\code\\lambda_dynamodb\\lambda_dynamodb.py"
      source_zip  = "modules\\lambda\\code\\lambda_dynamodb.zip"
    }
    lambda_email = {
      source_file = "modules\\lambda\\code\\lambda_email\\lambda_email.py"
      source_zip  = "modules\\lambda\\code\\lambda_email.zip"
    }
  }
}

variable "linux_paths" {
  description = "Paths for Linux OS"
  type = map(object({
    source_file = string
    source_zip  = string
  }))
  default = {
    lambda_detection = {
      source_file = "modules/lambda/code/lambda_detection/lambda_detection.py"
      source_zip  = "modules/lambda/code/lambda_detection.zip"
    }
    lambda_rekognition = {
      source_file = "modules/lambda/code/lambda_rekognition/lambda_rekognition.py"
      source_zip  = "modules/lambda/code/lambda_rekognition.zip"
    }
    lambda_dynamodb = {
      source_file = "modules/lambda/code/lambda_dynamodb/lambda_dynamodb.py"
      source_zip  = "modules/lambda/code/lambda_dynamodb.zip"
    }
    lambda_email = {
      source_file = "modules/lambda/code/lambda_email/lambda_email.py"
      source_zip  = "modules/lambda/code/lambda_email.zip"
    }
  }
}

# api gateway
