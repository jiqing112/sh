#!/bin/bash

# 这个脚本适用于支持systemd和ip命令的发行版，
# 脚本本质上是通过ip addr ip add命令配置ip，然后将ip addr add命令写入进一个sh脚本，通过systemd设置为开机自启
# 所以适用于centos 7、8、9 或者 ubuntu 、debian10 、debian12 
#!/bin/bash

interfaces=($(ip link show | awk -F': ' '/^[0-9]+:/ {print $2}'))

echo "可用网卡列表："
for i in "${!interfaces[@]}"; do
    echo "$i. ${interfaces[$i]}"
done

read -p "请输入要配置IP地址的网卡序号: " selected_interface_index

if ! [[ "$selected_interface_index" =~ ^[0-9]+$ ]] || ((selected_interface_index < 0 || selected_interface_index >= ${#interfaces[@]})); then
    echo "无效的网卡序号，请重新运行脚本并选择正确的网卡序号。"
    exit 1
fi

selected_interface=${interfaces[$selected_interface_index]}

ip_addresses=()

while true; do
    read -p "请输入要配置的IP地址（输入q退出）: " ip_address
    if [ "$ip_address" == "q" ]; then
        break
    fi
    if ! [[ "$ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "无效的IP地址，请重新输入正确的IP地址或输入q退出。"
    else
        ip_addresses+=("$ip_address")
    fi
done

for ip_address in "${ip_addresses[@]}"; do
    ip addr add $ip_address/24 dev $selected_interface
done

command=""

for ip_address in "${ip_addresses[@]}"; do
    command+="ip addr add $ip_address/24 dev $selected_interface\n"
done

if [ -f "/etc/network/add_extra_ip.sh" ]; then
    echo -e "$command" >> /etc/network/add_extra_ip.sh
else
    echo "#!/bin/bash" > /etc/network/add_extra_ip.sh
    echo -e "$command" >> /etc/network/add_extra_ip.sh
    chmod +x /etc/network/add_extra_ip.sh
fi

echo "[Unit]
Description=Add Extra IP Addresses
After=network.target

[Service]
ExecStart=/etc/network/add_extra_ip.sh

[Install]
WantedBy=default.target" > /etc/systemd/system/add_extra_ip.service

systemctl enable add_extra_ip.service

if [ $? -eq 0 ]; then
    echo "IP地址配置成功，并已将命令写入 /etc/network/add_extra_ip.sh 文件并创建了开机启动的service文件。"
else
    echo "IP地址配置失败。"
fi
