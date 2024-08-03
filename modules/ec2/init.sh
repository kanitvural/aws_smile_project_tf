#!/bin/bash

sleep 10
# Git deposunu klonla
sudo dnf update -y
sudo dnf install git python3.11 python3.11-pip nginx -y

sleep 20

# sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original

#nginx configuration for gradio

# sudo tee /etc/nginx/nginx.conf > /dev/null << EOL
# # For more information on configuration, see:
# #   * Official English Documentation: http://nginx.org/en/docs/
# #   * Official Russian Documentation: http://nginx.org/ru/docs/

# user nginx;
# worker_processes auto;
# error_log /var/log/nginx/error.log notice;
# pid /run/nginx.pid;

# # Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
# include /usr/share/nginx/modules/*.conf;

# events {
#     worker_connections 1024;
# }

# http {
#     log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
#                       '$status $body_bytes_sent "$http_referer" '
#                       '"$http_user_agent" "$http_x_forwarded_for"';

#     access_log  /var/log/nginx/access.log  main;

#     sendfile            on;
#     tcp_nopush          on;
#     keepalive_timeout   65;
#     types_hash_max_size 4096;

#     include             /etc/nginx/mime.types;
#     default_type        application/octet-stream;

#     # Load modular configuration files from the /etc/nginx/conf.d directory.
#     # See http://nginx.org/en/docs/ngx_core_module.html#include
#     # for more information.
#     include /etc/nginx/conf.d/*.conf;

#     server {

#         listen       80;
#         listen       [::]:80;
#         server_name  _;
#         root         /usr/share/nginx/html;

#         # Load configuration files for the default server block.
#         include /etc/nginx/default.d/*.conf;

#         error_page 404 /404.html;

	
#         location / {
# 	client_max_body_size 100M;
# 	proxy_pass http://127.0.0.1:7860/;
#         proxy_buffering off;
#         proxy_redirect off;
#         proxy_http_version 1.1;
#         proxy_set_header Upgrade $http_upgrade;
#         proxy_set_header Connection "upgrade";
#         proxy_set_header Host $host;
#         proxy_set_header X-Forwarded-Host $host;
#         proxy_set_header X-Forwarded-Proto $scheme;
# }
#         location = /404.html {
#         }

#         error_page 500 502 503 504 /50x.html;
#         location = /50x.html {
#         }
#     }

# # Settings for a TLS enabled server.
# #
# #    server {
# #        listen       443 ssl http2;
# #        listen       [::]:443 ssl http2;
# #        server_name  _;
# #        root         /usr/share/nginx/html;
# #
# #        ssl_certificate "/etc/pki/nginx/server.crt";
# #        ssl_certificate_key "/etc/pki/nginx/private/server.key";
# #        ssl_session_cache shared:SSL:1m;
# #        ssl_session_timeout  10m;
# #        ssl_ciphers PROFILE=SYSTEM;
# #        ssl_prefer_server_ciphers on;
# #
# #        # Load configuration files for the default server block.
# #        include /etc/nginx/default.d/*.conf;
# #
# #        error_page 404 /404.html;
# #        location = /404.html {
# #        }
# #
# #        error_page 500 502 503 504 /50x.html;
# #        location = /50x.html {
# #        }
# #    }

# }
# EOL

sudo systemctl enable nginx
sudo systemctl start nginx

sleep 10

# project download
git clone https://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@github.com/kntvrl/aws_smile_project_tf.git /home/ec2-user/aws_smile_project_tf

sleep 5

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






