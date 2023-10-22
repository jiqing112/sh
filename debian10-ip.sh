#!/bin/bash

# 获取所有网卡名称
interfaces=($(ip link show | awk -F': ' '/^[0-9]+:/ {print $2}'))

# 打印网卡列表供选择
echo "可用网卡列表："
for i in "${!interfaces[@]}"; do
    echo "$i. ${interfaces[$i]}"
done

# 提示用户选择网卡
read -p "请输入要配置IP地址的网卡序号: " selected_interface_index

# 确认选择的网卡序号是否有效
if ! [[ "$selected_interface_index" =~ ^[0-9]+$ ]] || ((selected_interface_index < 0 || selected_interface_index >= ${#interfaces[@]})); then
    echo "无效的网卡序号，请重新运行脚本并选择正确的网卡序号。"
    exit 1
fi

# 获取选择的网卡名称
selected_interface=${interfaces[$selected_interface_index]}

# 提示用户输入IP地址
read -p "请输入要配置的IP地址: " ip_address

# 执行配置IP地址命令
sudo ip addr add $ip_address dev $selected_interface

# 检查命令执行结果
if [ $? -eq 0 ]; then
    echo "IP地址配置成功。"
else
    echo "IP地址配置失败。"
fi
