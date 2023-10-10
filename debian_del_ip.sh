#!/bin/bash

# 备份 /etc/network/interfaces 文件
cp /etc/network/interfaces /etc/network/interfaces.bak

# 列举当前网卡设备
echo "可用的网卡设备："
interfaces=($(ip link show | awk -F': ' '{print $2}' | awk -F'@' '{print $1}'))
for i in "${!interfaces[@]}"; do
    echo "$(($i+1)). ${interfaces[$i]}"
done

# 提示用户选择网卡设备的序号
read -p "请输入网卡设备序号: " selected_interface_index

# 获取对应序号的网卡设备名称
selected_interface=${interfaces[$(($selected_interface_index-1))]}

# 检查网卡设备是否存在
if [[ -z $selected_interface ]]; then
    echo "无法找到对应的网卡设备，请检查序号是否正确。"
    # 恢复备份的 /etc/network/interfaces 文件
    mv /etc/network/interfaces.bak /etc/network/interfaces
    exit 1
fi

# 列出网卡上的虚拟接口IP地址
echo "网卡 $selected_interface 上的虚拟接口IP地址："
virtual_interfaces=($(grep -oP "(?<=iface $selected_interface:)[0-9]+" /etc/network/interfaces))
for i in "${!virtual_interfaces[@]}"; do
    virtual_interface_index=${virtual_interfaces[$i]}
    virtual_interface_ip=$(grep -A 3 "iface $selected_interface:$virtual_interface_index" /etc/network/interfaces | grep "address" | awk '{print $2}')
    echo "$(($i+1)). $selected_interface:$virtual_interface_index - $virtual_interface_ip"
done

# 提示用户选择要移除的虚拟接口IP地址的序号
read -p "请输入要移除的虚拟接口IP地址序号: " selected_ip_index

# 获取对应序号的虚拟接口IP地址
selected_interface_index=${virtual_interfaces[$(($selected_ip_index-1))]}

# 检查虚拟接口IP地址是否存在
if [[ -z $selected_interface_index ]]; then
    echo "无法找到对应的虚拟接口IP地址，请检查序号是否正确。"
    # 恢复备份的 /etc/network/interfaces 文件
    mv /etc/network/interfaces.bak /etc/network/interfaces
    exit 1
fi

# 移除选定的虚拟接口IP地址和相应的配置行（包括auto行）
sed -i "/iface $selected_interface:$selected_interface_index/,+4d" /etc/network/interfaces
sed -i "/auto $selected_interface:$selected_interface_index/d" /etc/network/interfaces

# 重启网络服务
systemctl restart networking

echo "虚拟接口IP地址 $selected_interface:$selected_interface_index 已成功移除。"
