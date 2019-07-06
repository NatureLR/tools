#!/bin/bash

# 判断是否已经安装了zsh
if [ $(cat /etc/shells | grep -c "zsh") -eq 0 ]; then

    # sudo apt install zsh
    yum -y install zsh

fi

# 切换shel到zsh
chsh -s /bin/zsh

# 下载并装oy-my-zsh

wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

# 安装autosuggestions语法高亮
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# 安装autosuggestions 命令提示

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

cp zshrc.conf $HOME/.zshrc

source $HOME/.zshrc
