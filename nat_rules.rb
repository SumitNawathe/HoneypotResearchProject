#!/bin/env ruby

require './container.rb'
require './network.rb'

# set up nat between two containers
def nat (router_ip, container_ip)
  `sudo ip link set dev enp4s2 up`
  `sudo ip addr add #{router_ip}/24 brd + dev enp4s2`
  `sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination #{router_ip} --jump DNAT --to-destination #{container_ip}`
  `sudo iptables --table nat --insert POSTROUTING --source #{container_ip} --destination 0.0.0.0/0 --jump SNAT --to-source #{router_ip}`
end

# set up nat between router and all containers
def nat_router_container
  for container in (n.containers)
    $container_ip = `sudo lxc-info -n container.name | grep "IP" | awk '{ print $2 }'`
    nat router_ip, container_ip
  end
end

def allow_single_container_connection(router, container)
  `sudo iptables -I FORWARD -p tcp -s #{router.ip} -d #{container.ip} -j ACCEPT`
end

def allow_container_connections(network)
  for container in network.containers
    allow_single_container_connection(network.router, container)
  end
end

def disallow_single_container_connection(router, container)
  `sudo iptables -D FORWARD -p tcp -s #{router.ip} -d #{container.ip} -j ACCEPT`
end

def disallow_container_connections(network)
  for container in network.containers
    disallow_single_container_connection(network.router, container)
  end
end


