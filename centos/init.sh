# 为centos最小化安装的环境脚本
#! /bin/bash

ROOTPATH=$HOME/linux-config

log() {
    echo -e "\033[1;32m$1\033[0m"
}

install() {
    log 安装$1
    yum -y install $1 >> log
}

# 执行目录在home目录
cd ~ 

#*************************安全策略***********************************
log 关闭firewall防火墙
systemctl stop firewalld && systemctl disable firewalld

log 关闭selinux
setenforce 0 && sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config

#*************************修改源***********************************

log yum源切换源阿里云
mkdir /etc/yum.repos.d/bak && mv /etc/yum.repos.d/*repo /etc/yum.repos.d/bak
curl -s -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo

install  https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm
sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*

log 创建yum缓存
yum makecache
#*************************日志策略*********************************

journalctl --vacuum-time=3d
journalctl --vacuum-size=1000M

#*************************安装常用软件*********************************

install git 
install wget 
install htop 
install vim 
install net-tools 
install tar 
install tree 
install highlight
install make
install chrony

#*************************安装fzf*********************************

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all

#*************************安装zsh*********************************

install zsh
install util-linux-user 

log 变更shell到zsh
chsh -s $(which zsh)

# 需要翻墙不然可能会连接失败
# export http_proxy=http://192.168.1.85:1087;export https_proxy=http://192.168.1.85:1087

log 安装oh-myzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

log 安装语法高亮
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

log 安装自动补全
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

cp $ROOTPATH/zsh/zshrc.conf ~/.zshrc

source ~/.zshrc

unset http_proxy;unset https_proxy
#log 安装powerlevel10k主题
#git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

#*************************配置tmux*********************************

install tmux 
git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux
ln -s -f .tmux/.tmux.conf && cp $ROOTPATH/tmux/tmux.conf .tmux.conf.local

#*************************安装配置docker*********************************

install https://download.docker.com/linux/centos/7/x86_64/edge/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm 
sudo curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
mkdir /etc/docker/ && cp $ROOTPATH/docker/daemon.json /etc/docker/
sudo systemctl start docker && sudo systemctl enable docker
