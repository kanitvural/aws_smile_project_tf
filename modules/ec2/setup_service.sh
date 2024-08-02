#!/bin/bash
# setup_service.sh

cat <<EOL | sudo tee /etc/systemd/system/smile.service
[Unit]
Description=Smile Python Application
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/aws_smile_project/
ExecStart=/home/ec2-user/aws_smile_project/venv/bin/python3 /home/ec2-user/aws_smile_project/smile_app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl start smile.service
sudo systemctl enable smile.service
