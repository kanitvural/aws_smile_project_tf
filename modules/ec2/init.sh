#!/bin/bash


# Git deposunu klonla
sudo dnf update -y
sudo dnf install git python3.11 python3.11-pip -y
sudo dnf install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
git clone https://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@github.com/kntvrl/aws_smile_project_tf.git /home/ec2-user/aws_smile_project_tf


# service kurulumu
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
sudo systemctl start smile.service
sudo systemctl enable smile.service


# ortama paket yükleme

cd /home/ec2-user/aws_smile_project_tf
python3.11 -m venv venv

if [ $? -ne 0 ]; then
    echo "Venv could not be created"
    exit 1
fi


source venv/bin/activate
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "Package initialization work failed!"
    exit 1
fi






