output "instance_id" {
  value = module.ec2.instance_id
}

output "public_ip" {
  value = module.ec2.public_ip
}

output "ec2_public_dns" {
  value = module.ec2.ec2_public_dns
}

output "recognition_url" {
  value = module.api_gateway.recognition_url
}

output "records_url" {
  value = module.api_gateway.records_url
}

output "email_url" {
  value = module.api_gateway.email_url
}

output "detection_url" {
  value = module.api_gateway.detection_url
}