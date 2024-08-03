variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "lambda_detection_arn" {
  description = "ARN of the detection Lambda function"
  type        = string
}

variable "lambda_rekognition_arn" {
  description = "ARN of the rekognition Lambda function"
  type        = string
}

variable "lambda_records_arn" {
  description = "ARN of the records Lambda function"
  type        = string
}

variable "lambda_email_arn" {
  description = "ARN of the email Lambda function"
  type        = string
}

