#!/bin/bash

# 获取所有screen会话的ID列表
sessions=$(screen -ls | grep -oE "[0-9]+\..*" | cut -d '.' -f1)

# 循环遍历每个会话并发送quit命令退出
for session in $sessions
do
    screen -X -S $session quit
done

