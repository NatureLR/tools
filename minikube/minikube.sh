#! /bin/bash

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

rancher(){
    log 安装rancher
    # 添加rancher的repo仓库，这里是用latest，生产环境推荐使用stable，尝鲜使用alpha
    helm repo add rancher-latest http://rancher-mirror.oss-cn-beijing.aliyuncs.com/server-charts/latest

    # 为rancher创建namespace
    kubectl create namespace cattle-system

    # 安装rancher
    helm install rancher rancher-latest/rancher \
     --namespace cattle-system \
     --set hostname=rancher.naturelr.cc
    
    kubectl -n cattle-system scale deployment rancher  --replicas 1 
    kubectl -n cattle-system rollout status deployment rancher
}

cert_manager(){
    log 安装cert-manager
    # 添加helm仓库
    helm repo add jetstack https://charts.jetstack.io
    
    # 更新仓库
    helm repo update
    
    # 创建cert-manager的namespace
    kubectl create namespace cert-manager
    
    # 使用helm安装cert-manager
    helm install \
     cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --set installCRDs=trues

    kubectl -n cert-manager rollout status deployment cert-manager
    kubectl -n cert-manager rollout status deployment cert-manager-cainjector
    kubectl -n cert-manager rollout status deployment cert-manager-webhook
    sleep 1m
}

gitlab(){
    helm install gitlab gitlab/gitlab \
    --namespace gitlab \
    --set global.hosts.domain=git.nature.cc \
    --set certmanager-issuer.email=naturelr@nature.cc
}

cilium(){
    log 安装 cilium
    minikube ssh -- sudo mount bpffs -t bpf /sys/fs/bpf

    helm repo add cilium https://helm.cilium.io/

    #helm install cilium cilium/cilium --namespace=kube-system
    #helm upgrade cilium cilium/cilium --reuse-values \

    helm install cilium cilium/cilium \
      --namespace kube-system \
      --set prometheus.enabled=true \
      --set operator.prometheus.enabled=true \
      --set metrics.enabled="{dns:query;ignoreAAAA;destinationContext=pod-short,drop:sourceContext=pod;destinationContext=pod,tcp,flow,port-distribution,icmp,http}" \
      --set hubble.listenAddress=":4244" \
      --set hubble.relay.enabled=true \
      --set hubble.ui.enabled=true \
      --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}"
    
    kubectl -n kube-system scale deployment cilium-operator --replicas 1
    kubectl -n kube-system rollout status deployment cilium-operator
    kubectl -n kube-system rollout status DaemonSet cilium
}

cni(){

    cilium

}

install(){
    minikube start  --network-plugin=cni \
                --memory=8g --cpus=4 \
                --bootstrapper=kubeadm \
                --extra-config=kubelet.authentication-token-webhook=true \
                --extra-config=kubelet.authorization-mode=Webhook \
                --extra-config=scheduler.address=0.0.0.0 \
                --extra-config=controller-manager.address=0.0.0.0
    log =============minikube启动完成=============
}

# 因为macos的网络限制只能使用端口转发
port_forward(){
    kubectl port-forward -n cattle-system svc/rancher 8080:80 8443:443
    kubectl port-forward -n kube-system   svc/hubble-ui --address 0.0.0.0 --address :: 12000:80
}

main(){
    #install
    #cni
    #cert_manager
    rancher
}

main "$@"
