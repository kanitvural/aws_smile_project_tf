variable "ami_id" {
  description = "AMI ID to launch EC2 instance"
  default     = "ami-02b6c3b7e67e2c9d6"  # Use a valid AMI ID for your region
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
}
