 
echo "系统巡检脚本：Version `date +%F`"
echo "天籁飞翔"
echo -e "****************系统检查****************"
echo "系统：`uname -a | awk '{print $NF}'`"
echo "发行版本：`cat /etc/redhat-release`"
echo "内核：`uname -r`"
echo "主机名：`hostname`"
echo "SELinux：`/usr/sbin/sestatus | grep 'SELinux status:' | awk '{print $3}'`"
echo "语言/编码：`echo $LANG`"
echo "当前时间：`date +%F_%T`"
echo "最后启动：`who -b |#!/bin/bash
 awk '{print $3,$4}'`"
echo "运行时间：`uptime | awk '{print $3}' | sed 's/,//g'`"
echo -e "****************CPU检查 ****************"
echo "物理CPU个数: `cat /proc/cpuinfo | grep "physical id" | awk '{print $4}' | sort | uniq | wc -l`"
echo "逻辑CPU个数: `cat /proc/cpuinfo | grep "processor" | awk '{print $3}' | sort | uniq | wc -l`"
echo "每CPU核心数: `cat /proc/cpuinfo | grep "cores" | awk '{print $4}'`"
echo "CPU型号: `cat /proc/cpuinfo | grep "model name" | awk -F":" '{print $2}'`"
echo "CPU架构: `uname -m`"
echo -e "****************内存检查 ****************"
echo "总共内存：`free -mh | awk "NR==2"| awk '{print $2}'`"
echo "使用内存：`free -mh | awk "NR==2"| awk '{print $3}'` "
echo "剩余内存：`free -mh | awk "NR==2"| awk '{print $4}'`"
echo -e "****************硬盘检查 ****************"
echo "总共磁盘大小：`df -hT | awk "NR==2"|awk '{print $3}'`"
echo -e "****************网络检查 ****************"
echo  "IP：  `ifconfig | awk 'NR==2' | awk '{print $2}'`"
echo "网关：`ip route | awk 'NR==1'| awk '{print $3}'`"
echo "DNS: `cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}'`"
ping -c 4 www.baidu.com > /dev/null
if [ $? -eq 0 ];then
    echo "外网连接：正常"
else
    echo "外网连接：失败    请检查DNS配置"
fi
echo -e "****************安全检查****************"
echo "登陆用户信息：`last | grep "still logged in" | awk '{print $1}'| sort | uniq`"
md5sum -c --quiet /etc/passwd > /dev/null 2&>1
