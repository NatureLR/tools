#! /bin/bash
set -e

log(){
  printf "\n"
  echo -e '\e[92m'$1链$2表'\e[0m'
}

log PREROUTING raw
iptables -nvL PREROUTING -t raw
log PREROUTING mangle
iptables -nvL PREROUTING -t mangle
log PREROUTING nat
iptables -nvL PREROUTING -t nat


log INUT mangle
iptables -nvL INPUT -t mangle
log INUT nat
iptables -nvL INPUT -t nat
log INUT filter
iptables -nvL INPUT -t filter


log INUT filter
iptables -nvL FORWARD -t mangle
log INUT filter
iptables -nvL FORWARD -t filter

log OUTPUT raw
iptables -nvL OUTPUT -t raw
log OUTPUT mangle
iptables -nvL OUTPUT -t mangle
log OUTPUT nat
iptables -nvL OUTPUT -t nat
log OUTPUT filter
iptables -nvL OUTPUT -t filter

log POSTROUTING mangle
iptables -nvL POSTROUTING -t mangle
log POSTROUTING nat
iptables -nvL POSTROUTING -t nat