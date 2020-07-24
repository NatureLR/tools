# centos 最小化 linux环境配置

此项配置为centos最小化安装的环境配置主要为了试验性质而非生产

## 关闭安全设置

1. systemctl stop firewalld && systemctl disable firewalld

2. setenforce 0 && sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config

## 修改源

1. mkdir /etc/yum.repos.d/bak && mv /etc/yum.repos.d/*repo /etc/yum.repos.d/bak

2. curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo

3. yum -y install   https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm

4. sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*

5. sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*

6. yum makecache

## 安装一些常用的软件

1. yum -y install  git wget htop vim net-tools tar tree highligh make

## 安装zsh

1. yum -y install zsh util-linux-user

2. chsh -s $(which zsh)

3. sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

3. git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

4. git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

4. cp $ROOTPATH/zsh/zshrc.conf ~/.zshrc

5. source ~/.zshrc

## FZF

1. git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all

## tmux

1. yum -y install tmux

2. `git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux`

3. ln -s -f .tmux/.tmux.conf && cp $ROOTPATH/tmux/tmux.conf .tmux.conf.local

## docker

1. wget https://download.docker.com/linux/centos/7/x86_64/edge/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm 

2. yum -y install  containerd.io-1.2.6-3.3.el7.x86_64.rpm

3. sudo curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

4. sudo usermod -aG docker $USER

5. mkdir /etc/docker/ && cp $ROOTPATH/docker/daemon.json /etc/docker/

6. sudo systemctl start docker && sudo systemctl enable docker
