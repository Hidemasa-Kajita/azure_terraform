#!/bin/bash

## dockerでのデプロイに切り替える

echo -e '[nginx]\nname=nginx repo\nbaseurl=http://nginx.org/packages/centos/7/$basearch/\ngpgcheck=0\nenabled=1\n' > /home/azureuser/nginx.repo

sudo mv /home/azureuser/nginx.repo /etc/yum.repos.d/nginx.repo

sudo yum install nginx -y

sudo systemctl start nginx

sudo systemctl enable nginx