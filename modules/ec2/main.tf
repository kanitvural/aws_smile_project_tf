resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, 0)
  key_name       = aws_key_pair.smile_key.key_name
  security_groups = [data.aws_security_group.default.id]
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
sudo dnf update -y
sudo dnf install git python3.11 python3.11-pip -y
git clone https://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@github.com/kntvrl/aws_smile_project.git
cd /home/ec2-user/aws_smile_project
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
sudo tee /etc/systemd/system/smile.service > /dev/null << EOL
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
sudo dnf install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
sudo tee /etc/nginx/nginx.conf > /dev/null << EOL
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {

        listen       80;
        listen       [::]:80;
        server_name  smile.deeplearning.vision; # --------> buraya site ismi yazılıyor
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;

	# nginx gradio ayarları
        location / {
	client_max_body_size 100M; # görüntü yükleme boyutu izni
	proxy_pass http://127.0.0.1:7860/;
        proxy_buffering off;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
}
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#        location = /404.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#        location = /50x.html {
#        }
#    }

}
EOL
sudo systemctl restart nginx
EOF

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
