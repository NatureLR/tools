#! /bin/bash

function log() {
    echo -e "\E[1;32m$1\E[0m"
}

function yum_install() {
    log 安装$1
    yum -y install $1 >> log
}

log 关闭firewall防火墙
systemctl stop firewalld && systemctl disable firewalld

log 关闭selinux
setenforce 0 && sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config


*************************修改源***********************************

log yum源切换源阿里云

mkdir /etc/yum.repos.d/bak && mv /etc/yum.repos.d/*repo /etc/yum.repos.d/bak

curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo

log epel源改为阿里云
yum_install  https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm

sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*

yum makecache

*************************安装zsh*********************************

yum_install util-linux-user git wget htop vim net-tools tmux tar tree vim

*************************安装zsh*********************************

log 安装oh-myzsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

log 安装语法高亮
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

log 安装自动补全
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

*************************配置tmux*********************************

git clone https://github.com/gpakosz/.tmux.git $HOME
cd && ln -s -f .tmux/.tmux.conf && cp .tmux/.tmux.conf.local 