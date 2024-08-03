#!/bin/bash


# Git deposunu klonla
sudo dnf update -y
sudo dnf install git python3.11 python3.11-pip -y
sudo dnf install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
git clone https://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@github.com/kntvrl/aws_smile_project_tf.git /home/ec2-user/aws_smile_project_tf

chmod +x /home/ec2-user/aws_smile_project_tf/setup_env.sh
chmod +x /home/ec2-user/aws_smile_project_tf/setup_service.sh


# Ortamı ayarla
bash /home/ec2-user/aws_smile_project_tf/setup_env.sh

# Servisi ayarla
bash /home/ec2-user/aws_smile_project_tf/setup_service.sh
