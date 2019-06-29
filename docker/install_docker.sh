#! /bin/bash

#定义颜色
RED_COLOR='\E[1;31m'   #红
GREEN_COLOR='\E[1;32m' #绿
YELOW_COLOR='\E[1;33m' #黄
BLUE_COLOR='\E[1;34m'  #蓝
PINK='\E[1;35m'        #粉红
RES='\E[0m'

echo -e "${GREEN_COLOR}下载docker官方安装脚本${RES}"
sudo curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

echo -e "${GREEN_COLOR}使用163镜像${RES}"
sudo mkdir -p /etc/docker/
sudo cp  daemon.json /etc/docker/

echo -e "${GREEN_COLOR}启动Docker${RES}"
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker


