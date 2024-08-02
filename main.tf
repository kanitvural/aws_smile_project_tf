

provider "aws" {
  region = "eu-west-2" # Londra bölgesi
}


module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source    = "./modules/ec2"
  subnet_ids = module.vpc.subnet_ids
  vpc_id     = module.vpc.vpc_id

}


module "s3" {
  source = "./modules/s3"
}