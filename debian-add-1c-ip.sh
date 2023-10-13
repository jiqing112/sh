#!/bin/bash

# 用户选择网卡
echo "请选择要配置的网卡："
select interface in $(ls /sys/class/net); do
    break
done

# 用户输入IP地址
echo "请输入IP地址（例如192.168.0.1）："
read -r ip

# 将用户输入的IP地址转换为网络地址
IFS='.' read -ra ip_parts <<< "$ip"
network="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}"

# 添加虚拟接口配置
for i in {1..254}; do
    echo "auto ${interface}:${i}" >> /etc/network/interfaces
    echo "iface ${interface}:${i} inet static" >> /etc/network/interfaces
    echo "    address ${network}.${i}" >> /etc/network/interfaces
    echo "    netmask 255.255.255.0" >> /etc/network/interfaces
done

# 重启网络服务
service networking restart
