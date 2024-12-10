#! /bin/bash
# 通过任意一个etcd节点即可获取整个集群的信息
# set -x

ca="/etc/kubernetes/ssl/ca.pem"
crt="/etc/kubernetes/ssl/etcd.pem"
key="/etc/kubernetes/ssl/etcd-key.pem"
# 当前节点的地址
default="http://127.0.0.1:2379" 

export ETCDCTL_API=3

cmdEtcd="etcdctl --cacert=$ca --cert=$crt --key=$key --endpoints=$default"

EDS=$(EDS=$($cmdEtcd member list -w  json | jq  -r '.members[].clientURLs[]' |tr '\n' ','); echo "${EDS%?}")

default=$EDS

cmdEtcd="etcdctl --cacert=$ca --cert=$crt --key=$key --endpoints=$default"

echo "$cmdEtcd" "$@"
$cmdEtcd "$@"
