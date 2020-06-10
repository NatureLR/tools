# kali linux 环境配置

## 切换语言为中文

1. dpkg–reconfigure locales

2. 使用空格勾选`en_us.UTF_8 UTF_8` 、`zh_CN.GBK GBK`、`zh_CN.UTF_8 UTF_8`

3. 重启

## 安装zsh

1. 切换到`chsh -s /bin/zsh`

2. 安装oh-my-zsh`sh -c "$(curl -fsSL --retry 10 --connect-timeout 3 https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`没有科学上网时有几率会失败

3. 安装自动补全插件`git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions`

4. 安装语法高亮`git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting`

## 安装常用的软件

1. sudo apt install  htop fzf highlight
