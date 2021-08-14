# docker

* 增加国内加速镜像,使用163的镜像

* 日志最大为30m,最多为10个文件

* 修改默认网桥地址为169.254.123.1/24

* 最大镜像同时上传下载数为10个

* 存储驱动为verlay2

## 常用命令

* docker volume rm $(docker volume ls -qf dangling=true) 清理无用volume
