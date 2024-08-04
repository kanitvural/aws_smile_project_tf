provider "aws" {
  region = "eu-west-2" # londra region
}

# module "vpc" {
#   source = "./modules/vpc"
# }

# module "ec2" {
#   source    = "./modules/ec2"
#   subnet_ids = module.vpc.subnet_ids
#   vpc_id     = module.vpc.vpc_id
# }

# module "s3" {
#   source = "./modules/s3"
# }


# LAMBDA
locals {
  is_linux   = length(regexall("/home/", lower(abspath(path.root)))) > 0
  is_windows = length(regexall("c:\\\\", lower(abspath(path.root)))) > 0
  is_macos   = length(regexall("/users/", lower(abspath(path.root)))) > 0

  os_type = (
    local.is_linux || local.is_macos ? "linux" :
    local.is_windows ? "windows" :
    "unknown"
  )

  os_paths = (
    local.os_type == "windows" ? var.windows_paths :
    var.linux_paths
  )

  lambda_functions = [
    for fn in var.lambda_functions : {
      function_name = fn.function_name
      handler       = fn.handler
      runtime       = fn.runtime
      source_file   = local.os_paths[fn.function_name].source_file
      source_zip    = local.os_paths[fn.function_name].source_zip
      timeout       = fn.timeout
    }
  ]
}

# IAM roles
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_admin_access" {
  role      = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
}


module "lambda" {
  source           = "./modules/lambda"
  lambda_functions = local.lambda_functions
  lambda_role_arn  = aws_iam_role.lambda_execution_role.arn
  os_type          = local.os_type
}


# API GATAWAY


module "api_gateway" {
  source = "./modules/api_gateway"

  aws_region               = "eu-west-2"
  lambda_detection_arn     = module.lambda.lambda_function_arns[0]
  lambda_rekognition_arn   = module.lambda.lambda_function_arns[1]
  lambda_records_arn       = module.lambda.lambda_function_arns[2]
  lambda_email_arn         = module.lambda.lambda_function_arns[3]
}



