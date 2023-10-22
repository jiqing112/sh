#!/bin/bash

# 这个配置IP的脚本可能不适用于debian10 ，请谨慎再debian10上使用

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

# 提示用户输入IP地址
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

# 提示用户输入子网掩码
read -p "请输入子网掩码（如果不输入，默认为255.255.255.0）: " subnet_mask

# 如果没有输入子网掩码，则默认使用255.255.255.0
if [[ -z $subnet_mask ]]; then
    subnet_mask="255.255.255.0"
fi

# 将虚拟接口的配置写入 /etc/network/interfaces 文件
existing_interface_indexes=$(grep -oP "(?<=iface $selected_interface:)[0-9]+" /etc/network/interfaces)
if [[ -z $existing_interface_indexes ]]; then
    interface_index=1
else
    interface_index=$(($(echo "$existing_interface_indexes" | sort -n | tail -n 1) + 1))
fi

for ip_address in "${ip_addresses[@]}"; do
    echo -e "\nauto $selected_interface:$interface_index" >> /etc/network/interfaces
    echo -e "iface $selected_interface:$interface_index inet static" >> /etc/network/interfaces
    echo -e "address $ip_address" >> /etc/network/interfaces
    echo -e "netmask $subnet_mask" >> /etc/network/interfaces
    ((interface_index++))
done

# 重启网络服务
systemctl restart networking

# 检测IP连通性
failed_ips=()
for ip_address in "${ip_addresses[@]}"; do
    ping -c 1 "$ip_address" >/dev/null
    if [[ $? -ne 0 ]]; then
        failed_ips+=("$ip_address")
    fi
done

if [[ ${#failed_ips[@]} -gt 0 ]]; then
    echo "脚本执行失败，以下IP地址无法连通："
    for failed_ip in "${failed_ips[@]}"; do
        echo "$failed_ip"
    done
    # 恢复备份的 /etc/network/interfaces 文件
    mv /etc/network/interfaces.bak /etc/network/interfaces
    exit 1
fi

systemctl restart networking

echo "虚拟接口已成功创建并配置。"
