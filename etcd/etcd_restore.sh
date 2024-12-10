#! /bin/bash

# 通过etcd快照恢复一服务

export ETCDCTL_API=3 
# 获取eth0网卡ipv4
#local_ip=$(ip -4 addr show eth0  | grep inet | awk '{print $2}' | cut -d/ -f1)
local_ip="127.0.0.1"
name="etcd-cluster-v2bfz9vrj8"
snapshot="snapshot.db"
  
# 备份快照
snapshot(){
  etcdctl snapshot save $snapshot --endpoints=localhost:2379
}

# 通过快照恢复目录
restore(){
  etcdctl snapshot restore $snapshot \
    --data-dir /var/lib/etcd \
    --name $name \
    --initial-cluster $name=http://"$local_ip":2380 \
    --initial-cluster-token restore \
    --initial-advertise-peer-urls http://"$local_ip":2380
}

# 运行参数
run(){
  etcd --data-dir=/var/lib/etcd \
    --name=$name \
    --initial-advertise-peer-urls=http://"$local_ip":2380 \
    --listen-peer-urls=http://0.0.0.0:2380 \
    --listen-client-urls=http://0.0.0.0:2379 \
    --advertise-client-urls=http://"$local_ip":2379 \
    --initial-cluster-state=existing
}

# 测试命令 
test(){
  ETCDCTL_API=3 etcdctl get / --prefix --keys-only
}

main(){
    case $1 in
    snapshot)
        snapshot;;
    restore)
        restore;;
    run)
        run;;
    esac
}

main "$@"