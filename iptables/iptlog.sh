#! /bin/bash
# 用于测试的脚本

set -e

log() {
    iptables -t raw    $1 PREROUTING  $2 -j LOG --log-prefix "target in raw.prerouting>"
    iptables -t mangle $1 PREROUTING  $2 -j LOG --log-prefix "target in mangle.prerouting>"
    iptables -t nat    $1 PREROUTING  $2 -j LOG --log-prefix "target in nat.prerouting>"
    iptables -t mangle $1 INPUT       $2 -j LOG --log-prefix "target in mangle.input>"
    iptables -t filter $1 INPUT       $2 -j LOG --log-prefix "target in filter.input>"
    iptables -t raw    $1 OUTPUT      $2 -j LOG --log-prefix "target in raw.output>"
    iptables -t mangle $1 OUTPUT      $2 -j LOG --log-prefix "target in mangle.output>"
    iptables -t nat    $1 OUTPUT      $2 -j LOG --log-prefix "target in nat.output>"
    iptables -t filter $1 OUTPUT      $2 -j LOG --log-prefix "target in filter.output>"
    iptables -t mangle $1 FORWARD     $2 -j LOG --log-prefix "target in mangle.forward>"
    iptables -t filter $1 FORWARD     $2 -j LOG --log-prefix "target in filter.forward>"
    iptables -t mangle $1 POSTROUTING $2 -j LOG --log-prefix "target in mangle.postrouting>"
    iptables -t mangle $1 POSTROUTING $2 -j LOG --log-prefix "target in nat.postrouting>"
}

onlog() {
    log "-I" "-p tcp --dport 80"
    echo "tail -f /var/log/messages 或者 dmesg -T"
}

offlog() {
    log "-D" "-p tcp --dport 80"
}

main() {
    case $1 in
    "on")
        onlog;;
    "off")
        offlog;;
    esac
}

main "$@"