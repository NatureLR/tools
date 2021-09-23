#!/usr/bin/env bash

set -e
#set -x

#项目根目录
ROOT_DIR=$(cd `dirname $0` ; pwd)
#各个组件配置目录
CONDIF_FILE=$ROOT_DIR/../config

# 输出日志
log() {
    logfile=./log
    msg="$(date +'%F %H:%M:%S')\t[$1]\t$2\033[0m"

    case $1 in
    info)
        echo  "\033[32m$msg" | tee -a $logfile
        ;;
    warn)
        echo -e "\033[33m$msg" | tee -a $logfile
        ;;
    err)
        echo -e "\033[31m$msg" | tee -a $logfile
        ;;
    *)
        echo -e "\033[32m$msg" | tee -a $logfile
        ;;
    esac
}

# 获取操作系统
get_os() {
    os=$(cat /etc/*-release | grep ^ID= | awk -F '=' '{print$2}' | sed 's/\"//g')
    os_version=$(cat /etc/*-release | grep ^VERSION_ID= | awk -F '=' '{print$2}' | sed 's/\"//g')
    os=$os$os_version
    log info 当前系统为：$os
}

# 系统包管理程序安装
install() {
    case $os in
    centos*)
        install_cmd="yum install -y"
        ;;
    ubuntu*)
        install_cmd="apt install -y"
        ;;
    alpine*)
        install_cmd="apk add"
        ;;
    esac

    for app in $*; do
        log 安装$app
        $install_cmd $app
    done
}

# 常用软件
app() {
    case $os in
    centos*)
        install the_silver_searcher chrony
        ;;
    ubuntu*)
        install silversearcher-ag
        ;;
    alpine*)
        install_cmd="apk add"
        ;;
    esac

    # 公共安装
    install git curl wget htop vim net-tools tar tree highlight make
}

# 防火墙设置
firewall() {
    case $os in
    centos*)
        log info 关闭firewall防火墙
        systemctl stop firewalld && systemctl disable firewalld
        ;;
    esac
}

selinux() {
    case $os in
    centos*)
        log info 关闭selinux
        setenforce 0 && sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
        ;;
    esac
}

# 包管理工具源修改
package_managers_source() {
    case $os in
    centos8)
        # centos8
        log info yum源切换源阿里云
        mkdir /etc/yum.repos.d/bak && mv /etc/yum.repos.d/*repo /etc/yum.repos.d/bak
        curl -s -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
        install https://mirrors.aliyun.com/epel/epel-release-latest-8.noarch.rpm
        sed -i 's|^#baseurl=https://download.fedoraproject.org/pub|baseurl=https://mirrors.aliyun.com|' /etc/yum.repos.d/epel*
        sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*
        log 创建yum缓存
        yum makecache
        ;;
    ubuntu*)
        log info apt源切换源阿里云
        sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
        apt update
        ;;
    alpine) ;;

    *)
        log err 不支持的操作系统！
        ;;
    esac
}

# 由于顺序问题fzf安装时没有zsh没法
fzf_conf() {
    log info 安装fzf_conf
    cp $CONDIF_FILE/fzf/.fzf.zsh $HOME/.fzf.zsh 
}

fzf() {
    log info 安装fzf
    case $os in
    centos*)
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
        fzf_conf
        ;;
    ubuntu*)
        apt install fzf
    esac
}

zsh_conf() {
    log 安装zsh配置文件
    cp $CONDIF_FILE/zsh/.zshrc $HOME/.zshrc
}

zsh() {
    log info 安装并配置ZSH
    case $os in
    centos*)
        install which util-linux-user;;
    ubuntu*)
        ;;
    esac

    install zsh 
    log 变更shell到zsh
    chsh -s $(which zsh)

    log 安装oh-myzsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    log 安装语法高亮
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    log 安装自动补全
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

    zsh_conf
    $(which zsh)
}

tmux_conf() {
    log info 生成tmux.conf.local
    cp -f $CONDIF_FILE/tmux/.tmux.conf.local $HOME/.tmux.conf.local
}

tmux() {
    log info 安装tmux
    case $os in
    centos* | ubuntu*)
        install tmux
        git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux
        ln -s -f ~/.tmux/.tmux.conf ~
        tmux_conf
        ;;
    esac
}

vim_conf() {
    log info 配置vim
    cp $CONDIF_FILE/vim/.vimrc $HOME/.vimrc
}

docker_conf() {
    log info 配置docker
    cp $CONDIF_FILE/docker/daemon.json /etc/docker/daemon.json
}

docker() {
    log info 安装docker
    install https://download.docker.com/linux/centos/7/x86_64/edge/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    usermod -aG docker $USER
    mkdir /etc/docker/
    docker_conf
    systemctl start docker && systemctl enable docker
}

git_conf() {
    cp $CONDIF_FILE/git/.gitconfig $HOME/.gitconfig
}

install_all() {
    get_os
    # 安全设置,容器中和生产环境不需要执行
    selinux
    firewall
    # 软件源
    package_managers_source
    # 常用软件安装
    app
    git_conf
    # 命令行相关
    tmux
    vim_conf
    fzf
    zsh
    docker
}

main(){
    case $1 in
    selinux)
        selinux
    ;;
    firewall)
        firewall
    ;;
    package-managers)
        package_managers_source
    ;;
     app)
        app
    ;;   
    git-conf)
        git_conf
    ;;
    vim-conf)
        vim_conf
    ;;
    fzf)
        fzf
    ;;
    zsh)
        zsh
    ;;
    *)
        install_all
    ;;
    esac
}

main "$@"
