#!/bin/bash

# kill all recycle processes
for PID in $( sudo ps -a -x | grep "recycle_script" | awk '{ print $1 }' ); do
  sudo kill -9 "$PID"
done
sleep 5

# destroy all containers
for CONTAINER in $( sudo lxc-ls ); do
  sudo lxc-destroy -f -s "$CONTAINER"
done

# stop forever scripts
sudo forever stopall

