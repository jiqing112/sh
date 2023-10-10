


# centos_add_ip.sh
CentOS 添加 IP 脚本：

在 CentOS 系统中添加一个新的 IP 地址到虚拟网卡文件(设备)。  
它会列出当前可用的网卡硬件设备，并提示用户选择。  
用户需要输入要添加的 IP 地址和子网掩码。  
脚本会在 /etc/sysconfig/network-scripts/ 目录下创建一个新的虚拟网卡文件，并配置用户指定的 IP 地址和子网掩码。  
脚本会重启网络服务应用  




# cnetos_del_ip.sh
CentOS 删除 IP 脚本：  

在 CentOS 系统中删除一个指定的 IP 地址(基于虚拟网卡文件)。  
它会列出当前已有的虚拟网卡文件，并提示用户选择要删除的虚拟网卡设备的IP。  
然后列出该选择虚拟网卡设备的所有 IP 地址，并提示用户选择要删除的 IP 地址。  
脚本会删除选定的虚拟网卡设备文件，并重启网络服务应用。  


# debian_add_ip.sh
Debian 添加 IP 脚本：  

在 Debian 系统中添加一个新的 IP 地址刀interface文件。  
用户需要输入要添加的 IP 地址和子网掩码。  
脚本会在 /etc/network/interfaces 文件中添加一个新的配置段，配置【虚拟网卡名】、【指定的 IP 】和【子网掩码】。  
最后脚本会重启网络应用。  


# debian_del_ip.sh
Debian 删除 IP 脚本：  

在 Debian 系统中删除一个指定的 IP 地址(操作/etc/network/interfaces文件)。  
它会列出当前网卡文件的虚拟接口，并提示用户选择要删除 IP 的虚拟网卡设备。  
脚本会从 /etc/network/interfaces 文件中删除选定的 IP 地址的配置段，并重启网络服务以应用更改。  
