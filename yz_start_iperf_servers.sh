#!/bin/bash
source /etc/profile  # 可能存储全局环境变量的文件
export PATH=$PATH:/usr/local/bin

# 获取 bond0 端口中的所有地址并存储到数组中
FIRST_IPS=($(ip addr show p4p1 | grep -oP 'inet \K[\d.]+'))
SECOND_IPS=($(ip addr show p4p2 | grep -oP 'inet \K[\d.]+'))

# 启动iperf服务端
start_iperf_server() {
    local ports_start=$1
    local ips=("${!2}")
    local port=$ports_start
    for ip in "${ips[@]}"; do
        screen -S iperf${port} -d -m bash -c "iperf3 -s -p $port -B $ip"
        ((port++))
    done
}

start_iperf_server 5101 FIRST_IPS[@]
start_iperf_server 5201 FIRST_IPS[@]
start_iperf_server 5301 FIRST_IPS[@]
start_iperf_server 5401 SECOND_IPS[@]
start_iperf_server 5501 SECOND_IPS[@]
start_iperf_server 5601 SECOND_IPS[@]



date -R >> /home/flowing/iperf_flow.log
echo "开启服务端" >> /home/flowing/iperf_flow.log

