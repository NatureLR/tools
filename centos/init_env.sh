echo "关闭firewalld防火墙"
# 停止firewalld服务
systemctl stop firewalld
# 关闭开机启动
systemctl disable firewalld

echo "关闭SELINUX"
# 设置当前selinux为permissive
setenforce 0
# 永久关闭selunx
sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config