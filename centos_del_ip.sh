#!/bin/bash

# 列举当前网卡设备
echo "可用的网卡设备："
interfaces=($(ip link show | awk -F': ' '{print $2}' | awk -F'@' '{print $1}'))
for i in "${!interfaces[@]}"; do
    echo "$(($i+1)). ${interfaces[$i]}"
done

# 提示用户选择要删除IP的虚拟网卡设备
read -p "请选择要删除IP的虚拟网卡设备编号： " choice
choice=$((choice-1))

# 检查选择是否有效
if [[ ! "${interfaces[$choice]}" ]]; then
    echo "选择无效，请重新运行脚本并选择正确的设备编号。"
    exit 1
fi

# 列出当前虚拟网卡设备的IP地址
interface=${interfaces[$choice]}
interface_files=($(ls /etc/sysconfig/network-scripts/ifcfg-$interface:* 2>/dev/null))
if [[ ${#interface_files[@]} -eq 0 ]]; then
    echo "该虚拟网卡设备没有配置IP地址。"
    exit 1
fi

echo "当前虚拟网卡设备的IP地址："
for i in "${!interface_files[@]}"; do
    interface_file=${interface_files[$i]}
    ip_address=$(grep "IPADDR" $interface_file | awk -F'=' '{print $2}')
    echo "$(($i+1)). $interface_file - IP地址: $ip_address"
done

# 提示用户选择要删除的IP地址
read -p "请选择要删除的IP地址对应的虚拟网卡设备文件编号： " file_choice
file_choice=$((file_choice-1))

# 检查选择是否有效
if [[ ! "${interface_files[$file_choice]}" ]]; then
    echo "选择无效，请重新运行脚本并选择正确的文件编号。"
    exit 1
fi

# 删除选定的虚拟网卡设备文件
rm ${interface_files[$file_choice]}

# 重启网络服务以应用更改
systemctl restart network

echo "已成功删除虚拟网卡设备的IP地址。"
