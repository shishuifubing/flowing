#!/bin/bash
source /etc/profile  # 可能存储全局环境变量的文件
export PATH=$PATH:/usr/local/bin

# 获取 bond0 端口中的第一个和第二个地址
FIRST_IPS=($(ip addr show p4p1 | grep -oP 'inet \K[\d.]+'))
SECOND_IPS=($(ip addr show p4p2 | grep -oP 'inet \K[\d.]+'))

# 获取-c后面的地址
IPERF_SERVERS=("150.139.143.132" "150.139.143.134" "150.139.143.136" "150.139.143.133" "150.139.143.135" "150.139.143.137")
IPERF_SERVERS1=("150.139.143.132" "150.139.143.134" "150.139.143.136")
IPERF_SERVERS2=("150.139.143.133" "150.139.143.135" "150.139.143.137")

# 设置-b参数为位置参数
BANDWIDTH="$1"

# 停止之前的打流
for session_id in $(screen -ls | awk '/iperf_out_/ {print $1}'); do
    screen -X -S $session_id quit
done


# 启动iperf客户端打流
start_iperf_client() {
    local server=$1
    local ip=$2
    local port=$3
    screen -S iperf_out_${port}_$server -d -m bash -c "iperf3 -c $server -i 5 -b $BANDWIDTH -p $port -t 30600 -B $ip -u"
}

#YZ和QD就是FIRST_IPS数量不一样，所以脚本中port的位置也不一样
for server in "${IPERF_SERVERS1[@]}"; do
    port=5101
    for ip in "${FIRST_IPS[@]}"; do
        start_iperf_client $server $ip $port
	((port++))
    done
done

for server in "${IPERF_SERVERS2[@]}"; do
    port=5401
    for ip in "${SECOND_IPS[@]}"; do
        start_iperf_client $server $ip $port
	((port++))
    done
done

date -R >> /home/flowing/iperf_flow.log
echo "开始打流$1" >> /home/flowing/iperf_flow.log

