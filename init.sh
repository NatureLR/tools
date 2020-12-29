#!/usr/bin/env bash

set -e

# 输出日志
log() {
    logfile=./log
    msg="$(date +'%F %H:%M:%S')\t[$1]\t$2\033[0m"

    case $1 in
    info)
        echo -e "\033[32m$msg" | tee -a $logfile
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

# 防火墙设置
firewall() {
    log info 关闭firewall防火墙
    case $os in
    centos*)
        systemctl stop firewalld && systemctl disable firewalld
        ;;
    esac
}

selinux() {
    log info 关闭selinux
    case $os in
    centos*)
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
    ubuntu) ;;

    alpine) ;;

    *)
        log err 不支持的操作系统！
        ;;
    esac
}

# 由于顺序问题fzf安装时没有zsh没法
fzf_conf() {
cat >~/.fzf.zsh <<EOF
# Setup fzf
# ---------
if [[ ! "$PATH" == */root/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/root/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/root/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/root/.fzf/shell/key-bindings.zsh"
EOF
}

fzf() {
    log info 安装fzf
    case $os in
    centos*)        
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
        fzf_conf
        ;;
    esac
}

zsh_conf() {
    log 安装zsh配置文件
    cat >~/.zshrc <<EOF
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="ys"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
# ZSH_THEME_RANDOM_CANDIDATES="ys"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    z
    git
    extract
    colorize
    github
    docker
    docker-compose
    zsh-autosuggestions
    zsh-syntax-highlighting
    python
    golang
    kubectl
)
# 此处变量需要转义
source \$ZSH/oh-my-zsh.sh

# 关闭共享历史命令
unsetopt share_history

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# mac 下目录显示颜色
export LSCOLORS="exfxcxdxbxexexabagacad"

# Go环境变量
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run $(alias).
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ll="ls -lAF"
alias la='ls -A'
alias l='ls -CF'
alias zshconfig="vim ~/.zshrc"
alias vimconfig="vim ~/.vimrc"
alias grep='grep --color=auto'
alias fzfv="fzf --height 80% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500'" # fzf 预览设置

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# fzf配置需
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# kubectl 语法补全
#source <(kubectl completion zsh)
EOF
}

zsh() {
    log info 安装并配置ZSH
    case $os in
    centos8)
        install zsh which
        install util-linux-user

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
        ;;
    esac
}

tmux_conf() {
    cat >~/.tmux.conf.local <<EOF
# https://github.com/gpakosz/.tmux
# (‑●‑●)> dual licensed under the WTFPL v2 license and the MIT license,
#         without any warranty.
#         Copyright 2012— Gregory Pakosz (@gpakosz).


# -- navigation ----------------------------------------------------------------

# if you're running tmux within iTerm2
#   - and tmux is 1.9 or 1.9a
#   - and iTerm2 is configured to let option key act as +Esc
#   - and iTerm2 is configured to send [1;9A -> [1;9D for option + arrow keys
# then uncomment the following line to make Meta + arrow keys mapping work
#set -ga terminal-overrides "*:kUP3=\e[1;9A,*:kDN3=\e[1;9B,*:kRIT3=\e[1;9C,*:kLFT3=\e[1;9D"


# -- windows & pane creation ---------------------------------------------------

# new window retains current path, possible values are:
#   - true
#   - false (default)
tmux_conf_new_window_retain_current_path=false

# new pane retains current path, possible values are:
#   - true (default)
#   - false
tmux_conf_new_pane_retain_current_path=true

# new pane tries to reconnect ssh sessions (experimental), possible values are:
#   - true
#   - false (default)
tmux_conf_new_pane_reconnect_ssh=false

# prompt for session name when creating a new session, possible values are:
#   - true
#   - false (default)
tmux_conf_new_session_prompt=false


# -- display -------------------------------------------------------------------

# RGB 24-bit colour support (tmux >= 2.2), possible values are:
#  - true
#  - false (default)
tmux_conf_theme_24b_colour=false

# window style
tmux_conf_theme_window_fg='default'
tmux_conf_theme_window_bg='default'

# highlight focused pane (tmux >= 2.1), possible values are:
#   - true
#   - false (default)
tmux_conf_theme_highlight_focused_pane=false

# focused pane colours:
tmux_conf_theme_focused_pane_fg='default'
tmux_conf_theme_focused_pane_bg='#0087d7'               # light blue

# pane border style, possible values are:
#   - thin (default)
#   - fat
tmux_conf_theme_pane_border_style=thin

# pane borders colours:
tmux_conf_theme_pane_border='#444444'                   # gray
tmux_conf_theme_pane_active_border='#00afff'            # light blue

# pane indicator colours
tmux_conf_theme_pane_indicator='#00afff'                # light blue
tmux_conf_theme_pane_active_indicator='#00afff'         # light blue

# status line style
tmux_conf_theme_message_fg='#000000'                    # black
tmux_conf_theme_message_bg='#ffff00'                    # yellow
tmux_conf_theme_message_attr='bold'

# status line command style (<prefix> : Escape)
tmux_conf_theme_message_command_fg='#ffff00'            # yellow
tmux_conf_theme_message_command_bg='#000000'            # black
tmux_conf_theme_message_command_attr='bold'

# window modes style
tmux_conf_theme_mode_fg='#000000'                       # black
tmux_conf_theme_mode_bg='#ffff00'                       # yellow
tmux_conf_theme_mode_attr='bold'

# status line style
tmux_conf_theme_status_fg='#8a8a8a'                     # light gray
tmux_conf_theme_status_bg='#080808'                     # dark gray
tmux_conf_theme_status_attr='none'

# terminal title
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_terminal_title='#h ❐ #S ● #I #W'

# window status style
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_window_status_fg='#8a8a8a'              # light gray
tmux_conf_theme_window_status_bg='#080808'              # dark gray
tmux_conf_theme_window_status_attr='none'
tmux_conf_theme_window_status_format='#I #W'
#tmux_conf_theme_window_status_format='#{circled_window_index} #W'
#tmux_conf_theme_window_status_format='#I #W#{?window_bell_flag,🔔,}#{?window_zoomed_flag,🔍,}'

# window current status style
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_window_status_current_fg='#000000'      # black
tmux_conf_theme_window_status_current_bg='#00afff'      # light blue
tmux_conf_theme_window_status_current_attr='bold'
tmux_conf_theme_window_status_current_format='#I #W'
#tmux_conf_theme_window_status_current_format='#{circled_window_index} #W'
#tmux_conf_theme_window_status_current_format='#I #W#{?window_zoomed_flag,🔍,}'

# window activity status style
tmux_conf_theme_window_status_activity_fg='default'
tmux_conf_theme_window_status_activity_bg='default'
tmux_conf_theme_window_status_activity_attr='underscore'

# window bell status style
tmux_conf_theme_window_status_bell_fg='#ffff00'         # yellow
tmux_conf_theme_window_status_bell_bg='default'
tmux_conf_theme_window_status_bell_attr='blink,bold'

# window last status style
tmux_conf_theme_window_status_last_fg='#00afff'         # light blue
tmux_conf_theme_window_status_last_bg='default'
tmux_conf_theme_window_status_last_attr='none'

# status left/right sections separators
tmux_conf_theme_left_separator_main=''
tmux_conf_theme_left_separator_sub='|'
tmux_conf_theme_right_separator_main=''
tmux_conf_theme_right_separator_sub='|'
#tmux_conf_theme_left_separator_main='\uE0B0'  # /!\ you don't need to install Powerline
#tmux_conf_theme_left_separator_sub='\uE0B1'   #   you only need fonts patched with
#tmux_conf_theme_right_separator_main='\uE0B2' #   Powerline symbols or the standalone
#tmux_conf_theme_right_separator_sub='\uE0B3'  #   PowerlineSymbols.otf font, see README.md

# status left/right content:
#   - separate main sections with '|'
#   - separate subsections with ','
#   - built-in variables are:
#     - #{battery_bar}
#     - #{battery_hbar}
#     - #{battery_percentage}
#     - #{battery_status}
#     - #{battery_vbar}
#     - #{circled_session_name}
#     - #{hostname_ssh}
#     - #{hostname}
#     - #{loadavg}
#     - #{pairing}
#     - #{prefix}
#     - #{root}
#     - #{synchronized}
#     - #{uptime_y}
#     - #{uptime_d} (modulo 365 when #{uptime_y} is used)
#     - #{uptime_h}
#     - #{uptime_m}
#     - #{uptime_s}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_status_left=' ❐ #S | ↑#{?uptime_y, #{uptime_y}y,}#{?uptime_d, #{uptime_d}d,}#{?uptime_h, #{uptime_h}h,}#{?uptime_m, #{uptime_m}m,} '
tmux_conf_theme_status_right='#{prefix}#{pairing}#{synchronized} #{?battery_status, #{battery_status},}#{?battery_bar, #{battery_bar},}#{?battery_percentage, #{battery_percentage},} , %R , %d %b | #{username}#{root} | #{hostname} '

# status left style
tmux_conf_theme_status_left_fg='#000000,#e4e4e4,#e4e4e4'  # black, white , white
tmux_conf_theme_status_left_bg='#ffff00,#ff00af,#00afff'  # yellow, pink, white blue
tmux_conf_theme_status_left_attr='bold,none,none'

# status right style
tmux_conf_theme_status_right_fg='#8a8a8a,#e4e4e4,#000000' # light gray, white, black
tmux_conf_theme_status_right_bg='#080808,#d70000,#e4e4e4' # dark gray, red, white
tmux_conf_theme_status_right_attr='none,none,bold'

# pairing indicator
tmux_conf_theme_pairing='👓 '          # U+1F453
tmux_conf_theme_pairing_fg='none'
tmux_conf_theme_pairing_bg='none'
tmux_conf_theme_pairing_attr='none'

# prefix indicator
tmux_conf_theme_prefix='⌨ '            # U+2328
tmux_conf_theme_prefix_fg='none'
tmux_conf_theme_prefix_bg='none'
tmux_conf_theme_prefix_attr='none'

# root indicator
tmux_conf_theme_root='!'
tmux_conf_theme_root_fg='none'
tmux_conf_theme_root_bg='none'
tmux_conf_theme_root_attr='bold,blink'

# synchronized indicator
tmux_conf_theme_synchronized='🔒'     # U+1F512
tmux_conf_theme_synchronized_fg='none'
tmux_conf_theme_synchronized_bg='none'
tmux_conf_theme_synchronized_attr='none'

# battery bar symbols
tmux_conf_battery_bar_symbol_full='◼'
tmux_conf_battery_bar_symbol_empty='◻'
#tmux_conf_battery_bar_symbol_full='♥'
#tmux_conf_battery_bar_symbol_empty='·'

# battery bar length (in number of symbols), possible values are:
#   - auto
#   - a number, e.g. 5
tmux_conf_battery_bar_length='auto'

# battery bar palette, possible values are:
#   - gradient (default)
#   - heat
#   - 'colour_full_fg,colour_empty_fg,colour_bg'
tmux_conf_battery_bar_palette='gradient'
#tmux_conf_battery_bar_palette='#d70000,#e4e4e4,#000000'   # red, white, black

# battery hbar palette, possible values are:
#   - gradient (default)
#   - heat
#   - 'colour_low,colour_half,colour_full'
tmux_conf_battery_hbar_palette='gradient'
#tmux_conf_battery_hbar_palette='#d70000,#ff5f00,#5fff00'  # red, orange, green

# battery vbar palette, possible values are:
#   - gradient (default)
#   - heat
#   - 'colour_low,colour_half,colour_full'
tmux_conf_battery_vbar_palette='gradient'
#tmux_conf_battery_vbar_palette='#d70000,#ff5f00,#5fff00'  # red, orange, green

# symbols used to indicate whether battery is charging or discharging
tmux_conf_battery_status_charging='↑'       # U+2191
tmux_conf_battery_status_discharging='↓'    # U+2193
#tmux_conf_battery_status_charging='⚡ '    # U+26A1
#tmux_conf_battery_status_charging='🔌 '    # U+1F50C
#tmux_conf_battery_status_discharging='🔋 ' # U+1F50B

# clock style (when you hit <prefix> + t)
# you may want to use %I:%M %p in place of %R in tmux_conf_theme_status_right
tmux_conf_theme_clock_colour='#00afff'  # light blue
tmux_conf_theme_clock_style='24'


# -- clipboard -----------------------------------------------------------------

# in copy mode, copying selection also copies to the OS clipboard
#   - true
#   - false (default)
# on macOS, this requires installing reattach-to-user-namespace, see README.md
# on Linux, this requires xsel or xclip
tmux_conf_copy_to_os_clipboard=false


# -- user customizations -------------------------------------------------------
# this is the place to override or undo settings

# increase history size
#set -g history-limit 10000

# start with mouse mode enabled
set -g mouse on

# force Vi mode
#   really you should export VISUAL or EDITOR environment variable, see manual
#set -g status-keys vi
#set -g mode-keys vi

# replace C-b by C-a instead of using both prefixes
# set -gu prefix2
# unbind C-a
# unbind C-b
# set -g prefix C-a
# bind C-a send-prefix

# move status line to top
#set -g status-position top
EOF
}

tmux() {
    log info 安装tmux
    case $os in
    centos*)
        install tmux
        git clone https://github.com/gpakosz/.tmux.git $HOME/.tmux
        ln -s -f .tmux/.tmux.conf
        tmux_conf
        ;;
    esac
}

vim_conf() {
    log info 配置vim
    cat >~/.vimrc <<EOF
syntax on " 高亮
syntax enable
set number " 显示行号
set fencs=utf-8,usc-bom,euc-jp,gb18030,gbk,gb2312,cp936 " 设定默认解码 
set completeopt=longest,menu " 智能补全
filetype plugin on " 载入文件类型插件 
filetype indent on " 为特定文件类型载入相关缩进文件 
set showmatch      " 设置匹配模式
EOF
}

docker_conf() {
    cat >/etc/docker/daemon.json <<EOF
{
    "oom-score-adjust": -1000,
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "max-concurrent-downloads": 10,
    "max-concurrent-uploads": 10,
    "bip": "169.254.123.1/24",
    "registry-mirrors": ["http://hub-mirror.c.163.com"],
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ]
}
EOF
}

docker() {
    install https://download.docker.com/linux/centos/7/x86_64/edge/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker $USER
    mkdir /etc/docker/
    docker_conf
    systemctl start docker && systemctl enable docker
}

# 常用软件
app() {
    # 公共安装
    install git wget htop vim net-tools tar tree highlight make chrony
}

main() {
    get_os

    # 安全设置,容器中和生产环境不需要执行
    #selinux
    #firewall

    # 软件源
    package_managers_source
    yum -y install git

    # 常用软件安装
    #app

    # 命令行相关
    tmux
    vim_conf
    fzf
    zsh
    #docker
}

main "$@"
