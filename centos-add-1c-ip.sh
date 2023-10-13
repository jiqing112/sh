#!/bin/bash

# 遍历输出当前网卡设备
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

# 获取选择的网卡设备
interface=${interfaces[$choice]}

# 提示用户输入IP地址
read -p "请输入IP地址： " ip_address

# 使用正则表达式校验IP地址格式
ip_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
if [[ ! $ip_address =~ $ip_regex ]]; then
    echo "输入的IP地址格式不正确，请重新输入。"
    exit 1
fi

# 提取C段网络地址
c_network=$(echo "$ip_address" | awk -F'.' '{print $1"."$2"."$3}')

# 创建虚拟网卡接口配置文件
echo "正在配置虚拟网卡..."
created_interfaces=()
for ((i=1; i<=256; i++)); do
    ip="${c_network}.${i}"
    interface_file="/etc/sysconfig/network-scripts/ifcfg-$interface:$i"
    echo "DEVICE=\"$interface:$i\"" > $interface_file
    echo "BOOTPROTO=\"static\"" >> $interface_file
    echo "IPADDR=\"$ip\"" >> $interface_file
    echo "NETMASK=\"255.255.255.0\"" >> $interface_file
    echo "ONBOOT=\"yes\"" >> $interface_file

    created_interfaces+=("$interface:$i")
done

# 重启网络服务以应用更改
systemctl restart network

echo "已成功创建以下虚拟网卡接口："
for interface_name in "${created_interfaces[@]}"; do
    ip_address=$(grep "IPADDR" "/etc/sysconfig/network-scripts/ifcfg-$interface_name" | awk -F'=' '{print $2}')
    echo "$interface_name - IP地址: $ip_address"
done
