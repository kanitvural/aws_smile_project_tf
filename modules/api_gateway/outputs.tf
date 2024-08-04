output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = "${aws_api_gateway_rest_api.this.execution_arn}/p"
}

output "recognition_url" {
  value       = "${aws_api_gateway_deployment.this.invoke_url}/${aws_api_gateway_resource.rekognition.path_part}"
  description = "URL for the Rekognition endpoint"
}

output "records_url" {
  value       = "${aws_api_gateway_deployment.this.invoke_url}/${aws_api_gateway_resource.records.path_part}"
  description = "URL for the Records endpoint"
}

output "email_url" {
  value       = "${aws_api_gateway_deployment.this.invoke_url}/${aws_api_gateway_resource.email.path_part}"
  description = "URL for the Email endpoint"
}

output "detection_url" {
  value       = "${aws_api_gateway_deployment.this.invoke_url}/${aws_api_gateway_resource.detection.path_part}"
  description = "URL for the Detection endpoint"
}


