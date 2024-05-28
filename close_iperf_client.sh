#!/bin/bash
source /etc/profile  # 可能存储全局环境变量的文件
export PATH=$PATH:/usr/local/bin

for session_id in $(screen -ls | awk '/iperf_out_/ {print $1}'); do
    screen -X -S $session_id quit
done

#ps -ef|grep 'SCREEN -S iperf' |grep -v grep|awk '{print $2}'|xargs kill -9
date -R >> /home/flowing/iperf_flow.log
echo "停止打流" >> /home/flowing/iperf_flow.log
