#! /bin/bash
# 合并$HOME/.kube/configs目录下的文件到$HOME/.kube/config
# 配合kubectx工具进行环境切换
# 此方法有个缺陷，就是用户名如果一致且认证信息不一致则只保留了一个

CONFIGPATH=$HOME/.kube/configs

FILEPATH=

for C in `ls $CONFIGPATH/*yaml`;do
    echo "找到配置文件:"$C
    FILEPATH=$FILEPATH$C:
done

export KUBECONFIG=$FILEPATH

kubectl config view --raw > $HOME/.kube/config

unset KUBECONFIG
