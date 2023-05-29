#! /bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

_red()    { echo -e "${red}"     "$*" "${none}"; }
_green()  { echo -e "${green}"   "$*" "${none}"; }
_yellow() { echo -e "${yellow}"  "$*" "${none}"; }
_magenta(){ echo -e "${magenta}" "$*" "${none}"; }
_cyan()   { echo -e "${cyan}"    "$*" "${none}"; }
_none()   { echo -e "${none}"    "$*" "${none}"; }

# 为空则不输出到log文件
logfile=./log

# 定义日志函数
log() {
    local level="$1"
    local msg="$2"
    local color

    if [ $# -eq 1 ]; then
        msg="$1"
        level=""
    fi

    case $level in
    info)
        color=$green;;
    warn)
        color=$yellow;;
    err)
        color=$red;;
    *)
        color=$green
        level="";;
    esac

    local log_msg="$(date +'%F %H:%M:%S') $level $msg"

    if [ -n "$logfile" ]; then
        echo -e "${color}$log_msg${none}" | tee -a "$logfile"
    else
        echo -e "${color}$log_msg${none}"
    fi
}

# 调用日志函数输出日志
log "info" "info log"
log "err" "err log"
log "warn" "warn log"
log "default log"
