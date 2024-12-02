#! /bin/bash

set -e

# 输出日志
log() {
    logfile=./log
    msg="$(date +'%F %H:%M:%S')\t[$1]\t$2\033[0m"

    case $1 in
    info)
        echo -e "\033[32m$msg" | tee -a $logfile;;
    warn)
        echo -e "\033[33m$msg" | tee -a $logfile;;
    err)
        echo -e "\033[31m$msg" | tee -a $logfile;;
    *)
        echo -e "\033[32m$msg" | tee -a $logfile;;
    esac
}

monitoring() {
    git clone https://github.com/prometheus-operator/kube-prometheus.git
    cd kube-prometheus
    kubectl apply --server-side -f manifests/setup
    kubectl apply -f manifests/
}

loki() {
    helm repo add grafana https://grafana.github.io/helm-charts
    helm install loki grafana/loki-stack \
        --set grafana.enabled=true \
        --namespace loki \
        --create-namespace

    kubectl -n loki rollout status sts loki
    sleep 5s
}

rancher(){
    log 安装rancher
    # 添加rancher的repo仓库，这里是用latest，生产环境推荐使用stable，尝鲜使用alpha
    helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

    # 安装rancher
    helm install rancher rancher-latest/rancher \
     --namespace cattle-system \
     --create-namespace \
     --set replicas=1 \
     --set global.cattle.psp.enabled=false \
     --set hostname=rancher.naturelr.cc
    
    kubectl -n cattle-system rollout status deployment rancher
    # helm upgrade rancher rancher-latest/rancher  --reuse-values
}

cert_manager(){
    log 安装cert-manager
    # 添加helm仓库
    helm repo add jetstack https://charts.jetstack.io
    
    # 更新仓库
    helm repo update
    
    # 使用helm安装cert-manager
    helm install \
     cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --create-namespace \
     --set installCRDs=true

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

#   kubectl get secret <name>-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
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

calico(){
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
}

cni(){
    #cilium
    calico
}

install(){
    minikube start  \
        --network-plugin=cni \
        --memory=8g \
        --cpus=4 \
        --bootstrapper=kubeadm \
        --extra-config=kubelet.authentication-token-webhook=true \
        --extra-config=kubelet.authorization-mode=Webhook \
        --extra-config=scheduler.bind-address=0.0.0.0 \
        --extra-config=controller-manager.bind-address=0.0.0.0
    log =============minikube启动完成=============
}

# 因为macos的网络限制只能使用端口转发
port_forward(){
    kubectl port-forward -n cattle-system svc/rancher   8443:443 > /dev/null  2>&1 &
    #kubectl port-forward -n kube-system   svc/hubble-ui 12000:80 > /dev/null  2>&1 &
    #kubectl port-forward -n monitoring    svc/grafana   3000:3000 > /dev/null 2>&1 &
}

install_all(){
    install
    cni
    cert_manager
    rancher
    monitoring
    loki
}

help(){
    echo  ' ================================================================ '
    echo  ' 默认安装minikube配置为4c8g,cni使用calico,安装rancher'
    echo  ' minikube.sh 全部安装'
    echo  ' minikube.sh port-forward 端口转发rancher'
}

main(){
    case $1 in
    certmanager)
        cert_manager;;
    rancher)
        rancher;;
    cni)
        cni;;
    log)
        loki;;
    monitoring)
        monitoring;;
    port-forward)
        port_forward;;
    *)
        install_all;;
    esac
}

main "$@"
