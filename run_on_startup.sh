#!/bin/bash

PROJECT_DIR="/home/student/HoneypotResearchProject"
cd "$PROJECT_DIR"

# apply firewall rules
sudo "$PROJECT_DIR"/baseline_firewall_rules.sh || true

# increase inofity limits
sudo sysctl fs.inotify.max_user_instances=512
sudo sysctl fs.inotify.max_user_watches=4194304

# start all recycling scripts
sudo -u student bash <<EOF
cd "$PROJECT_DIR"
sleep 15
nohup ./recycle_script.rb 128.8.238.197 < /dev/null >/dev/null &
sleep 200
nohup ./recycle_script.rb 128.8.238.29 < /dev/null >/dev/null &
sleep 200
nohup ./recycle_script.rb 128.8.238.47 < /dev/null >/dev/null &
sleep 200
nohup ./recycle_script.rb 128.8.238.178 < /dev/null >/dev/null &
sleep 200
nohup ./recycle_script.rb 128.8.238.105 < /dev/null >/dev/null &
sleep 200
EOF

