#!/bin/bash
export LANG=zh_CN.UTF-8

set -e

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

_red()    { echo -e ${red}$*${none}; }
_green()  { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta(){ echo -e ${magenta}$*${none}; }
_cyan()   { echo -e ${cyan}$*${none}; }
_none()   { echo -e ${nonex}$*${none}; }

checkCMD() {
    for v in $*; do
        if type $v >/dev/null 2>&1; then
            _green "命令 $v 已经安装"
        else
            _magenta "命令 $v 未安装"
            exit 1
        fi
    done
}

choose_from_menu() {
    local prompt="$1" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]} index=0
    local esc=$(echo -en "\e") # cache ESC as test doesn't allow esc codes
    printf "$prompt\n"
    while true
    do
        # list all options (option list is zero-based)
        index=0 
        for o in "${options[@]}"
        do
            if [ "$index" == "$cur" ]
            then _green "> $o" # mark & highlight the current option
            else echo "  $o"
            fi
            index=$(( $index + 1 ))
        done
        read -s -n3 key # wait for user to key in arrows or ENTER
        if [[ $key == $esc[A ]] # up arrow
        then cur=$(( $cur - 1 ))
            [ "$cur" -lt 0 ] && cur=0
        elif [[ $key == $esc[B ]] # down arrow
        then cur=$(( $cur + 1 ))
            [ "$cur" -ge $count ] && cur=$(( $count - 1 ))
        elif [[ $key == "" ]] # nothing, i.e the read delimiter - ENTER
        then break
        fi
        echo -en "\e[${count}A" # go up to the beginning to re-render
    done
    # export the selection to the requested output variable
    printf -v $outvar "${options[$cur]}"
}

# 关闭selinux
selinuxset() {
   _none "========================禁用SELINUX========================"
   selinux_status=`grep "SELINUX=disabled" /etc/sysconfig/selinux | wc -l`
   if [ $selinux_status -eq 0 ];then
       sed  -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/sysconfig/selinux
       setenforce 0
       _magenta '#grep SELINUX=disabled /etc/sysconfig/selinux'
       grep SELINUX=disabled /etc/sysconfig/selinux
       _magenta '#getenforce'
       getenforce
   else
       _yellow 'SELINUX已处于关闭状态'
       echo '#grep SELINUX=disabled /etc/sysconfig/selinux'
       grep SELINUX=disabled /etc/sysconfig/selinux
       echo '#getenforce'
       getenforce
   fi
   _green "完成禁用SELINUX"
   _none "==========================================================="
}

# history优化
historyset() {
   _none "========================history优化========================"
   chk_his=`cat /etc/profile | grep HISTTIMEFORMAT |wc -l`
   if [ $chk_his -eq 0 ];then

   cat >> /etc/profile <<EOF
#设置history格式
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] [`whoami`] [`who am i|awk '{print $NF}'|sed -r 's#[()]##g'`]: "
#记录shell执行的每一条命令
export PROMPT_COMMAND='\
if [ -z "$OLD_PWD" ];then
    export OLD_PWD=$PWD;
fi;
if [ ! -z "$LAST_CMD" ] && [ "$(history 1)" != "$LAST_CMD" ]; then
    logger -t `whoami`_shell_dir "[$OLD_PWD]$(history 1)";
fi;
export LAST_CMD="$(history 1)";
export OLD_PWD=$PWD;'
EOF

   source /etc/profile
   else
    _yellow "优化项已存在。"
   fi
   _green "完成history优化"
   _none "==========================================================="
}

# 关闭firewalld
firewalldset() {
   _none "=======================禁用firewalld========================"
   systemctl stop firewalld.service &> /dev/null
   _magenta '#firewall-cmd  --state'
   firewall-cmd  --state
   systemctl disable firewalld.service &> /dev/null
   _magenta '#systemctl list-unit-files | grep firewalld'
   systemctl list-unit-files | grep firewalld
   _green "完成禁用firewalld,生产环境下建议启用!"
   _none "==========================================================="
}

# 设置时间同步
ntpdateset() {
   _none "=======================设置时间同步========================"
   yum -y install ntpdate &> /dev/null
   if [ $? -eq 0 ];then
      /usr/sbin/ntpdate time.windows.com
      echo "*/5 * * * * /usr/sbin/ntpdate ntp.aliyun.com &>/dev/null" >> /var/spool/cron/root
   else
      _red "ntpdate安装失败"
      exit $?
   fi
   _green "完成设置时间同步" /bin/true
   _none "==========================================================="
}

hostnameset() {
   _none "==========================================================="
   default=`ip r | grep default | awk -F "dev" '{print$2}'`    
   ip=`ip addr show $defalut | grep -oE '([0-9]{1,3}.?){4}/[0-9]{2}' | awk -F '/' '{print$1}'`  
   if [$HOSTNAME != $ip];then
      hostnamectl set-hostname $ip
      echo 'export PS1="[\u@\H \W]\$ ' >> /etc/profile
   fi
   _yellow "优化项已存在"
}

yumset() {
   _none "=================修改yum源====================================="
   yum install wget -y &> /dev/null
   if [ $? -eq 0 ];then
    cd /etc/yum.repos.d/ && cp CentOS-Base.repo CentOS-Base.repo.$(date +%F)
    ping -c 1 mirrors.aliyun.com &> /dev/null
      if [ $? -eq 0 ];then
        wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo &> /dev/null
        yum clean all &> /dev/null
        yum makecache &> /dev/null
      else
       _magenta "无法连接网络"
           exit $?
      fi
   else
      _red "wget安装失败"
      exit $?
   fi
   yum -y install ntpdate lsof net-tools telnet vim lrzsz tree nmap nc sysstat &> /dev/null
   _green "完成安装常用工具及修改yum源" /bin/true
   _none "==========================================================="
}

# 第一个参数是文件位置 第二参数是要修改的参数 要修改的值
updateconfig(){
   file=$1
   key=$2
   value=$3
   _yellow "修改$file中的$key为$value"
   # 判断文件中是否有该值
   # 有则修改
   # 没有则直接追加
   check=`grep -r -n "$key" $file |wc -l `
   if [ $check -eq 0 ];then
      echo "$key $value" >> $file
   else
      sed -i "s/.*$key.*/$key $value/g" $file
   fi
   _green "修改完成"
}

sshset(){
   _none "ssh 尝试登录改为3"
   updateconfig "/etc/ssh/sshd_config" "MaxAuthTries" "3"

   _none "打印最后登录日志"
   updateconfig "/etc/ssh/sshd_config" "PrintLastLog" "yes"

   systemctl restart sshd
}

all() {
    selinuxset
    firewalldset
    historyset
    hostnameset
    ntpdateset
    sshset
}

# 菜单
menu() {
clear
selections=(
"全部执行"
"关闭selinux"
"关闭firewalld"
"history优化"
"主机名优化"
"ssh优化"
"设置时间同步"
"退出"
)
choose_from_menu "请选择:" selected_choice "${selections[@]}"

case $selected_choice in
   "全部执行")
      all
      break;;
   "关闭selinux")
      selinuxset;;
   "关闭firewalld")
      firewalldset;;
   "history优化")
      historyset;;
   "主机名优化")
      hostnameset;;
   "ssh优化")
      sshset;;
   "设置时间同步")
      ntpdateset;;
   "退出")
      break;;
   *)
      _red "没有此选项";;
esac
sleep 3
clear
}

main() {
echo "##############################"
echo "#          优化脚本           #"
echo "##############################"

menu
}

main
