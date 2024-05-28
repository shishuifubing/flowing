#!/bin/bash
source /etc/profile  # 可能存储全局环境变量的文件
export PATH=$PATH:/usr/local/bin

# 获取 bond0 端口中的第一个和第二个地址
FIRST_IPS=($(ip addr show p2p1 | grep -oP 'inet \K[\d.]+'))
SECOND_IPS=($(ip addr show p2p2 | grep -oP 'inet \K[\d.]+'))

# 获取-c后面的地址
IPERF_SERVERS1=("117.91.188.226" "117.91.188.227" "117.91.188.228" "117.91.188.229" "117.91.188.230" "117.91.188.231" "117.91.188.232" "117.91.188.233" "117.91.188.234" "117.91.188.244" "117.91.188.245" "117.91.188.246" "117.91.188.247" "117.91.188.248" "117.91.188.249" "117.91.188.250" "117.91.188.251" "117.91.188.252" "117.91.182.139" "117.91.182.140" "117.91.182.141" "117.91.182.142" "117.91.182.143" "117.91.182.144" "117.91.182.145" "117.91.182.146" "117.91.182.147")
IPERF_SERVERS2=("117.91.188.235" "117.91.188.236" "117.91.188.237" "117.91.188.238" "117.91.188.239" "117.91.188.240" "117.91.188.241" "117.91.188.242" "117.91.188.243" "117.91.182.130" "117.91.182.131" "117.91.182.132" "117.91.182.133" "117.91.182.134" "117.91.182.135" "117.91.182.136" "117.91.182.137" "117.91.182.138" "117.91.182.148" "117.91.182.149" "117.91.182.150" "117.91.182.151" "117.91.182.152" "117.91.182.153" "117.91.182.154" "117.91.182.155" "117.91.182.156")

# 设置-b参数为位置参数
BANDWIDTH="$1"

# 停止之前的打流
for session_id in $(screen -ls | awk '/iperf_out_/ {print $1}'); do
    screen -X -S $session_id quit
done


# 修改之后的部分
# 启动iperf客户端打流
start_iperf_client() {
    local server=$1
    local ip=$2
    local port=$3
    screen -S iperf_out_${port}_$server -d -m bash -c "iperf3 -c $server -i 5 -b $BANDWIDTH -p $port -t 30600 -B $ip -u"
}

# 遍历IPERF_SERVERS1和IPERF_SERVERS2

port1=5101
for server in "${IPERF_SERVERS1[@]}"; do
    for ip in "${FIRST_IPS[@]}"; do
        start_iperf_client $server $ip $port1
        if ((port1 == 5109)); then
            port1=5100
        fi
    done
    ((port1++))
done

port2=5401
for server in "${IPERF_SERVERS2[@]}"; do
    for ip in "${FIRST_IPS[@]}"; do
        start_iperf_client $server $ip $port2
        if ((port2 == 5409)); then
            port2=5400
        fi
    done
    ((port2++))
done

date -R >> /home/flowing/iperf_flow.log
echo "开始打流$1" >> /home/flowing/iperf_flow.log


