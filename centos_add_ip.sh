#!/bin/bash

# 列举当前网卡设备
echo "可用的网卡设备："
interfaces=($(ip link show | awk -F': ' '{print $2}' | awk -F'@' '{print $1}'))
for i in "${!interfaces[@]}"; do
    echo "$(($i+1)). ${interfaces[$i]}"
done

# 提示用户选择网卡设备
read -p "请选择要创建虚拟网卡的设备编号： " choice
choice=$((choice-1))

# 检查选择是否有效
if [[ ! "${interfaces[$choice]}" ]]; then
    echo "选择无效，请重新运行脚本并选择正确的设备编号。"
    exit 1
fi

# 创建虚拟网卡接口配置文件
echo "输入完所有IP地址后，请输入'q'退出。"
ip_addresses=()
while true; do
    read -p "请输入IP地址（或输入'q'退出）: " ip_address
    if [[ $ip_address == "q" ]]; then
        break
    fi

    # 使用正则表达式校验IP地址格式
    ip_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    if [[ ! $ip_address =~ $ip_regex ]]; then
        echo "输入的IP地址格式不正确，请重新输入。"
        continue
    fi

    ip_addresses+=("$ip_address")
done

interface=${interfaces[$choice]}
created_interfaces=()
for j in "${!ip_addresses[@]}"; do
    # 检查接口配置文件是否已存在
    k=0
    while [[ -f "/etc/sysconfig/network-scripts/ifcfg-$interface:$k" ]]; do
        ((k++))
    done

    # 创建虚拟网卡的 ifcfg 文件
    interface_file="/etc/sysconfig/network-scripts/ifcfg-$interface:$k"
    echo "DEVICE=\"$interface:$k\"" > $interface_file
    echo "BOOTPROTO=\"static\"" >> $interface_file
    echo "IPADDR=\"${ip_addresses[$j]}\"" >> $interface_file
    echo "NETMASK=\"255.255.255.0\"" >> $interface_file
    echo "ONBOOT=\"yes\"" >> $interface_file

    created_interfaces+=("$interface:$k")
done

# 重启网络服务以应用更改
systemctl restart network

echo "已成功创建以下虚拟网卡接口："
for interface_name in "${created_interfaces[@]}"; do
    ip_address=$(grep "IPADDR" "/etc/sysconfig/network-scripts/ifcfg-$interface_name" | awk -F'=' '{print $2}')
    echo "$interface_name - IP地址: $ip_address"
done
