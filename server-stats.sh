#!/bin/bash

# server-stats.sh - Linux服务器性能统计脚本

# 检查脚本是否在Linux上运行
if [[ "$(uname)" != "Linux" ]]; then
    echo "错误：此脚本只能在Linux系统上运行"
    exit 1
fi

echo -e "\n\033[1;34m==== Linux服务器性能统计报告 ====\033[0m"

# 1. 系统基本信息
echo -e "\n\033[1;32m[系统信息]\033[0m"
echo "主机名: $(hostname)"
echo "操作系统: $(grep "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)"
echo "内核版本: $(uname -r)"
echo "架构: $(uname -m)"

# 2. 正常运行时间与负载
echo -e "\n\033[1;32m[正常运行时间与负载]\033[0m"
uptime | awk -F'[ ,]+' '{print "正常运行时间: " $3 " " $4 ", 用户: " $8, "平均负载: " $(NF-2), $(NF-1), $(NF)}'

# 3. CPU使用率
echo -e "\n\033[1;32m[CPU使用率]\033[0m"
echo "总CPU利用率: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *$[0-9.]*$%* id.*/\1/" | awk '{print 100 - $1"%"}')"
echo -e "\n\033[1;36m-- 按CPU使用率排名前5进程 --\033[0m"
ps -eo pid,user,%cpu,cmd --sort=-%cpu | head -n 6

# 4. 内存使用情况
echo -e "\n\033[1;32m[内存使用]\033[0m"
free -m | awk 'NR==2{printf "已用/总共: %s/%sMB (%.2f%%)\n", $3,$2,$3 * 100/$2 }'

echo -e "\n\033[1;36m-- 按内存使用率排名前5进程 --\033[0m"
ps -eo pid,user,%mem,rss,cmd --sort=-%mem | head -n 6

# 5. 磁盘使用情况
echo -e "\n\033[1;32m[磁盘使用]\033[0m"
df -h | grep -vE 'tmpfs|devtmpfs' | grep "/dev" | awk '{print $1 ": 已用/总共: " $3 "/" $2 " (" $5 ")"}'

# 6. 用户登录信息
echo -e "\n\033[1;32m[用户信息]\033[0m"
echo -e "登录用户:\n$(who | awk '{print $1, $2, $3, $4}' | column -t)"
echo -e "\n最近登录失败尝试: $(sudo lastb 2>/dev/null | wc -l) 次"

# 7. 网络连接统计
echo -e "\n\033[1;32m[网络统计]\033[0m"
ss -s | head -2

# 8. 安全警示（可选）
echo -e "\n\033[1;32m[安全检测]\033[0m"
echo "开放的SSH端口: $(sudo netstat -tulpn | grep ":22")"
echo "失败登录尝试IP: $(sudo grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr | head -5)"

echo -e "\n\033[1;34m==== 报告生成时间: $(date) ====\033[0m\n"