#! /bin/bash
# 检查一些命令是否安装

function log {
    logfile=./log
    msg="`date +'%F %H:%M:%S'`\t[$1]\t$2\033[0m"

    case $1 in 
        info)
            echo -e "\033[32m"$msg | tee -a $logfile;;
        warn)
            echo -e "\033[33m$msg" | tee -a $logfile;;
        error)
            echo -e "\033[31m$msg" | tee -a $logfile;;
    esac
}

function checkCMD() {
    if type $1  >/dev/null 2>&1; then
        log info "工具 $1 安装成功"
    else 
        log error "工具 $1 安装失败"
    fi
}

########################需要检查的命令列表############################

checkCMD zsh 
checkCMD fzf
checkCMD tmux
checkCMD htop
checkCMD make
checkCMD vim
checkCMD docker
checkCMD tar
