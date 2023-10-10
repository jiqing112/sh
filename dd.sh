#!/bin/bash

# 备份原始的 SSH 配置文件
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 修改 SSH 配置文件，允许 root 远程登录并去掉端口为 22 的行的注释
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config

# 重启 SSH 服务
systemctl restart sshd

# 写入额外的文本到 /etc/network/interfaces 文件
echo "auto eno2" >> /etc/network/interfaces
echo "iface eno2 inet static" >> /etc/network/interfaces
echo "address 192.168.1.1" >> /etc/network/interfaces
