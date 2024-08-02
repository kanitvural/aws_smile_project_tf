variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "subnet_names" {
  description = "Names for the subnets"
  type        = list(string)
  default     = ["public_subnet_a", "public_subnet_b", "public_subnet_c"]
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}
