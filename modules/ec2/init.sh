#!/bin/bash

sleep 10
# Git deposunu klonla
sudo dnf update -y
sudo dnf install git python3.11 python3.11-pip nginx -y

sleep 20

# project download
git clone https://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@github.com/kntvrl/aws_smile_project_tf.git /home/ec2-user/aws_smile_project_tf

sleep 10


#nginx setup
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original
sudo cp /home/ec2-user/aws_smile_project_tf/nginx.conf /etc/nginx/nginx.conf
sudo systemctl enable nginx
sudo systemctl start nginx

# service setup
sudo tee /etc/systemd/system/smile.service > /dev/null <<EOL
[Unit]
Description=Smile Python Application
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/aws_smile_project_tf/
ExecStart=/home/ec2-user/aws_smile_project_tf/venv/bin/python3 /home/ec2-user/aws_smile_project_tf/smile_app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
# sudo systemctl start smile.service
# sudo systemctl enable smile.service


# setup venv
cd /home/ec2-user/aws_smile_project_tf
sudo python3.11 -m venv venv

source venv/bin/activate
pip install -r requirements.txt






