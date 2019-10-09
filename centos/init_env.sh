#! /bin/bash

WORKDIR=$(cd $(dirname $0); pwd)

#定义颜色
RED_COLOR='\E[1;31m'   #红
GREEN_COLOR='\E[1;32m' #绿
YELOW_COLOR='\E[1;33m' #黄
BLUE_COLOR='\E[1;34m'  #蓝
PINK='\E[1;35m'        #粉红
RES='\E[0m'

echo -e "${GREEN_COLOR}初始化:关闭firewalld防火墙${RES}"
# 停止firewalld服务
systemctl stop firewalld
# 关闭开机启动
systemctl disable firewalld

echo -e "${GREEN_COLOR}初始化:关闭SELINUX${RES}"
# 设置当前selinux为permissive
setenforce 0
# 永久关闭selunx
sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config

echo -e "${GREEN_COLOR}初始化:安装wget${RES}"
yum -y install wget

echo -e "${GREEN_COLOR}初始化:修改yum源为国内源${RES}"
#  创建备份文件夹
mkdir /etc/yum.repos.d/repo_bak
# 将官方的repo启动到备份文件夹中
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/repo_bak
# 下载repo文件到/etc/yum.repos.d/
wget -O /etc/yum.repos.d/CentOS7-Base-163.repo.repo  http://mirrors.163.com/.help/CentOS7-Base-163.repo
# 更新缓存
yum clean all 
yum makecache

echo -e "${GREEN_COLOR}初始化:安装EPEL${RES}"
#下载阿里开源镜像的epel源文件
wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo    

echo -e "${GREEN_COLOR}初始化:更新软件和系统${RES}"
yum -y update

# 安装ctop

sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.2/ctop-0.7.2-linux-amd64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

# 需要安装的软件列表
apps="vim net-tools git htop"

for app in $apps; do

    echo -e "${GREEN_COLOR}初始化:安装$app${RES}"
    yum -y install $app

done

# 安装docker
WORKDIR=$(cd $(dirname $0); pwd)
sh  $WORKDIR/../docker/install_docker.sh