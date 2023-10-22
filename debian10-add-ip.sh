#!/bin/bash

# 这个脚本适用于debian10 、debian12 ，
# 本质上是通过ip addr ip 命令配置ip，然后将命令写入到一个sh脚本，设置为开机自启
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

# 检查输入的IP地址是否符合规则
if ! [[ "$ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "无效的IP地址，请重新运行脚本并输入正确的IP地址。"
    exit 1
fi

ip addr add $ip_address/24 dev $selected_interface

# 拼接命令
command="ip addr add $ip_address/24 dev $selected_interface"

# 将命令写入文件
echo "#!/bin/bash" > /etc/network/add_extra_ip.sh
echo "$command" >> /etc/network/add_extra_ip.sh
chmod +x /etc/network/add_extra_ip.sh

# 设置开机启动
echo "@reboot root /etc/network/add_extra_ip.sh" | tee /etc/cron.d/add_extra_ip

# 检查命令执行结果
if [ $? -eq 0 ]; then
    echo "IP地址配置成功，并已将命令写入 /etc/network/add_extra_ip.sh 文件并设置为开机启动。"
else
    echo "IP地址配置失败。"
fi
