#!/bin/bash

cd /home/ec2-user/aws_smile_project_tf
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
