# home-server

在家里部署的服务提升生活幸福感

## 收录的服务

|名字|说明|默认端口|备注|
|---------------|--------------- |---|---|
transmission    | 下载器          |9091||
phpmyadmin      | 数据web管理工具  |9092||
home-assistant  | 智能家居        |9093|通过配置文件修改的端口|
adguardhome     | 去广告dns       |9094|通过而配置修改的端口|
tieba-cloud-sign| 百度贴吧自动签到 |9095||
nextcloud       | 私有网盘        |9096|此镜像根据官方添加了smb|

### nextcloud补充说明

```shell
# 使用主机cron上 （镜像不自带）
# 将下面的任务添加到宿主机的cron中
*/5 * * * * docker exec -u www-data nextcloud php cron.php
```
