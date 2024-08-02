resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, 0)
  key_name       = aws_key_pair.smile_key.key_name
  security_groups = [data.aws_security_group.default.id]
  associate_public_ip_address = true

  user_data = "${file("init.sh")}"

  tags = {
    Name = "SmileEC2Instance"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_role.name
}

data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
  vpc_id = var.vpc_id
}


resource "aws_security_group_rule" "allow_ssh" {
  type        = "ingress"
  from_port    = 22
  to_port      = 22
  protocol     = "tcp"
  security_group_id = data.aws_security_group.default.id
  cidr_blocks  = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_http" {
  type        = "ingress"
  from_port    = 80
  to_port      = 80
  protocol     = "tcp"
  security_group_id = data.aws_security_group.default.id
  cidr_blocks  = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_https" {
  type        = "ingress"
  from_port    = 443
  to_port      = 443
  protocol     = "tcp"
  security_group_id = data.aws_security_group.default.id
  cidr_blocks  = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_custom_port" {
  type        = "ingress"
  from_port    = 7860
  to_port      = 7860
  protocol     = "tcp"
  security_group_id = data.aws_security_group.default.id
  cidr_blocks  = ["0.0.0.0/0"]
}


resource "aws_key_pair" "smile_key" {
  key_name   = "smile2"
  public_key = file("C:/Users/iskorpittt/Desktop/smile2.pem.pub")
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "ec2_role" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
