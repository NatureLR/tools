#! /bin/bash

# 用于转储docker镜像到私有仓库的脚本

# 根据情况修改
repo="hub.docker.com"

name=`echo $1 |awk -F "/" '{print$2}'`

$repotag="$repo/$name"

echo "$1=====>$repotag"

docker pull $1
docker tag $1 $repotag
docker push $repotag
