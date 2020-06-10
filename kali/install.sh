#! /bin/bash

ROOTPATH=$HOME/linux-config

# 执行目录在home目录
cd ~

log() {
    echo -e "\033[1;32m$1\033[0m"
}

install() {
for app in $*
do
   log 安装$app
   sudo apt install -y $app >> log 2>&1 
done
}

##*************************安装常用软件*********************************

install htop fzf highlight

##*************************安装zsh***********************************

log 安装oh-myzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

log 安装语法高亮
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting >>log 2>&1 

log 安装自动补全
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions >>log 2>&1 

cp $ROOTPATH/zsh/zshrc.conf ~/.zshrc
