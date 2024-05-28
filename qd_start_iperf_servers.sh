#!/bin/bash
source /etc/profile  # 可能存储全局环境变量的文件
export PATH=$PATH:/usr/local/bin

# 获取 bond0 端口中的所有地址并存储到数组中
FIRST_IP=$(ip addr show p2p1 | grep -oP 'inet \K[\d.]+')
SECOND_IP=$(ip addr show p2p2 | grep -oP 'inet \K[\d.]+')

# 启动iperf服务端
start_iperf_server() {
    local port_start=$1
    local ip=$2
    for ((i=0; i<9; i++)); do
        port=$((port_start + i))
        screen -S iperf${port} -d -m bash -c "iperf3 -s -p $port -B $ip"
    done
}

start_iperf_server 5101 "$FIRST_IP"
start_iperf_server 5201 "$FIRST_IP"
start_iperf_server 5301 "$FIRST_IP"
start_iperf_server 5401 "$SECOND_IP"
start_iperf_server 5501 "$SECOND_IP"
start_iperf_server 5601 "$SECOND_IP"

date -R >> /home/flowing/iperf_flow.log
echo "开启服务端" >> /home/flowing/iperf_flow.log

