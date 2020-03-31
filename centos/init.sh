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

#*************************修改源***********************************

log yum源切换源阿里云
mkdir /etc/yum.repos.d/bak && mv /etc/yum.repos.d/*repo /etc/yum.repos.d/bak
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo

log epel源改为阿里云
yum_install  https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm

sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*

log 创建yum缓存
yum makecache

#*************************安装常用软件*********************************

yum_install git 
yum_install wget 
yum_install htop 
yum_install vim 
yum_install net-tools 
yum_install tar 
yum_install tree 
yum_install vim
yum_install highlight

#*************************安装zsh*********************************

yum_install zsh
yum_install util-linux-user 

log 变更shell到zsh
chsh -s $(which zsh)

# 需要翻墙不然可能会连接失败
#export https_proxy='http://192.168.1.215:1087'

log 安装oh-myzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
source ~/.zshrc

log 安装语法高亮
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

log 安装自动补全
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

cp ../zsh/zshrc.conf ~/.zshrc

#sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/g' ~/.zshrc

source ~/.zshrc

#log 安装powerlevel10k主题
#git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

#*************************配置tmux*********************************

yum_install tmux 
cd && git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf && cp ~/linux-config/tmux/tmux.conf .tmux.conf.local

#*************************安装fzf*********************************

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all

#*************************安装配置docker*********************************

wget https://download.docker.com/linux/centos/7/x86_64/edge/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm 
yum_install containerd.io-1.2.6-3.3.el7.x86_64.rpm
sudo curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo systemctl enable docker
