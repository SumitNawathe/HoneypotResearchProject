#!/bin/bash

# available ram in MB
grep "MemAvailable" /proc/meminfo | awk '{ print $2 / 1024 }'

# available disk in MB
df | grep "/dev/sh" | awk '{ print $4 / (1024 * 1024) }'

# 15 min system load
sudo uptime | rev | awk '{ print $1 }' | rev

# RX kilobytes
ifconfig enp4s1 | grep "RX packets" | awk '{ print $5 / 1024 }'

# TX kilobytes
ifconfig enp4s1 | grep "TX packets" | awk '{ print $5 / 1024 }'


