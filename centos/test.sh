#! /bin/bash
# 检查一些命令是否安装

function log {
    local text;local logtype
    logfile=./log.txt
    logtype=$1
    text=$2
    #其实可以再将日志的格式定义为一个字符串，这样就不用重复写`date +'%F %H:%M:%S'`\t$1\t$2\033[0m，又可以省好多代码。
    case $logtype in 
        error)
            echo -e "\033[31m`date +'%F %H:%M:%S'`\t$1\t$2\033[0m" | tee -a $logfile;;
        info)
            echo -e "\033[32m`date +'%F %H:%M:%S'`\t$1\t$2\033[0m" | tee -a $logfile;;
        warn)
            echo -e "\033[33m`date +'%F %H:%M:%S'`\t$1\t$2\033[0m" | tee -a $logfile;;
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
