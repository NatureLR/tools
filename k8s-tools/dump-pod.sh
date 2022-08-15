#! /bin/bash
# 输入节点名字导出该pod

regexp=`echo $* | sed 's/[ ][ ]*/|/g'`

kubectl get po -A  -o wide |grep -E $regexp |awk '{printf$8","$1","$2"\n"}' > pod.csv

echo "文件已经导出:pod.csv"
