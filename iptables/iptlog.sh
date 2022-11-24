#! /bin/bash
# 用于测试的脚本

set -e

condition="-p tcp -m multiport --dport 80"

log() {
    iptables -t raw    $1 PREROUTING  $2 -j LOG --log-prefix "raw.prerouting>"
    iptables -t mangle $1 PREROUTING  $2 -j LOG --log-prefix "mangle.prerouting>"
    iptables -t nat    $1 PREROUTING  $2 -j LOG --log-prefix "nat.prerouting>"
    iptables -t mangle $1 INPUT       $2 -j LOG --log-prefix "mangle.input>"
    iptables -t nat    $1 INPUT       $2 -j LOG --log-prefix "mangle.input>"
    iptables -t filter $1 INPUT       $2 -j LOG --log-prefix "filter.input>"
    iptables -t raw    $1 OUTPUT      $2 -j LOG --log-prefix "raw.output>"
    iptables -t mangle $1 OUTPUT      $2 -j LOG --log-prefix "mangle.output>"
    iptables -t nat    $1 OUTPUT      $2 -j LOG --log-prefix "nat.output>"
    iptables -t filter $1 OUTPUT      $2 -j LOG --log-prefix "filter.output>"
    iptables -t mangle $1 FORWARD     $2 -j LOG --log-prefix "mangle.forward>"
    iptables -t filter $1 FORWARD     $2 -j LOG --log-prefix "filter.forward>"
    iptables -t mangle $1 POSTROUTING $2 -j LOG --log-prefix "mangle.postrouting>"
    iptables -t nat    $1 POSTROUTING $2 -j LOG --log-prefix "nat.postrouting>"
}

onlog() {
    log "-I" "$condition"
    echo "tail -f /var/log/messages 或者 dmesg -T"
}

offlog() {
    log "-D" "$condition"
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