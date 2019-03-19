#!/bin/bash
yum install bash-completion-extras.noarch -y
echo -n "正在配置iptables防火墙……"
systemctl stop firewalld > /dev/null 2>&1
systemctl disable firewalld  > /dev/null 2>&1
if [ $? -eq 0 ];then
echo -n "Iptables防火墙初始化完毕！"
fi
 
echo -n "正在关闭SELinux……"
setenforce 0 > /dev/null 2>&1
sed -i '/^SELINUX=/s/=.*/=disabled/' /etc/selinux/config
if [ $? -eq 0 ];then
        echo -n "SELinux初始化完毕！"
fi

echo -n "正在安装Docker……"
yum install docker -y
if [ $? -eq 0 ];then
        echo -n "Docker安装完毕！"
fi
echo -n "正在配置Docker……"
#cat <<EOF >/etc/docker/daemon.json 
#{
#  "registry-mirrors": ["http://harbor.test.com"], 
#  "insecure-registries": ["harbor.test.com","registry.cn-shenzhen.aliyuncs.com"], 
#  "max-concurrent-downloads": 10
#}
#EOF

cat  <<EOF >/etc/containers/registries.conf |egrep -v "^#|^$"
[registries.search]
registries = ['registry.access.redhat.com', 'docker.io', 'registry.fedoraproject.org', 'quay.io', 'registry.centos.org']
[registries.insecure]
registries = []
[registries.block]
registries = []
[registries.insecure]
registries = [172.30.0.0/16]
EOF

systemctl eanble docker

scp docker.service /usr/lib/systemd/system/docker.service

systemctl daemon-reload

systemctl restart docker

echo -n "Docker配置完毕！"


echo -n "正在安装openshift all-in-one"
# yum list all | grep openshift
# yum info centos-release-openshift-origin37.noarch

yum install -y centos-release-openshift-origin37.noarch

yum install origin -y

if [ $? -eq 0 ];then
        echo -n "Openshift安装完毕！oc cluster up"
fi

