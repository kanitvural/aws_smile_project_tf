#!/bin/bash

sleep 10
# Git deposunu klonla
sudo dnf update -y
sudo dnf install git python3.11 python3.11-pip nginx -y

sleep 20

# project download
git clone https://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@github.com/kntvrl/aws_smile_project_tf.git /home/ec2-user/aws_smile_project_tf

sleep 10

# env update

aws s3 cp s3://kntbucketlondon/outputs.json /home/ec2-user/outputs.json

# JSON dosyasından değerleri oku
RECOGNITION_URL=$(jq -r '.recognition_url.value' /home/ec2-user/outputs.json)
RECORDS_URL=$(jq -r '.records_url.value' /home/ec2-user/outputs.json)
EMAIL_URL=$(jq -r '.email_url.value' /home/ec2-user/outputs.json)
DETECTION_URL=$(jq -r '.detection_url.value' /home/ec2-user/outputs.json)

# RECOGNITION_URL="${recognition_url}"
# RECORDS_URL="${records_url}"
# EMAIL_URL="${email_url}"
# DETECTION_URL="${detection_url}"

ENV_FILE="/home/ec2-user/aws_smile_project_tf/.env"

sed -i "s|^RECOGNITION_URL=.*|RECOGNITION_URL=$RECOGNITION_URL|" $ENV_FILE
sed -i "s|^RECORDS_URL=.*|RECORDS_URL=$RECORDS_URL|" $ENV_FILE
sed -i "s|^EMAIL_URL=.*|EMAIL_URL=$EMAIL_URL|" $ENV_FILE
sed -i "s|^DETECTION_URL=.*|DETECTION_URL=$DETECTION_URL|" $ENV_FILE

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
sudo systemctl start smile.service
sudo systemctl enable smile.service


# setup venv
cd /home/ec2-user/aws_smile_project_tf
sudo python3.11 -m venv venv

source venv/bin/activate
pip install -r requirements.txt






