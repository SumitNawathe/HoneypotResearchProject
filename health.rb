require './container'
require './network'

def print_host_health
  # available ram in MB
  puts `cat /proc/meminfo | grep "MemAvailable" | awk '{ print $2 / 1024 }'`
  # available disk in MB
  puts `df | grep "/dev/sdb" | awk '{ print $4 / (1024 * 1024) }'`
  # 15 min system load
  puts `sudo uptime | rev | awk '{ print $1 }' | rev`
  # RX megabytes
  puts `sudo ifconfig enp4s1 | grep "RX packets" | awk '{ print $5 / 1024 }'`
  # TX megabytes
  puts `sudo ifconfig enp4s1 | grep "TX packets" | awk '{ print $5 / 1024 }'`
end

def print_container_health container
  if !container.running?
    # container is not active
    puts "CONTAINER DOWN"
    4.times { puts "-" }
  end

  # used ram in MB
  puts `sudo lxc-info #{container.name} | grep "Memory use" | awk '{ print $3 }'`
  # used disk in MB
  puts `sudo lxc-attach -n #{container.name} -- df | grep "/dev/sdb" | awk '{ print $3 / (1024 * 1024) }'`
  # 15 min system load
  puts `sudo lxc-attach -n #{container.name} -- bash -c "uptime" | rev | awk '{ print $1 }' | rev`
  # RX megabytes
  puts `sudo lxc-info -n #{container.name} | grep "RX" | awk '{ print $3 }'`
  # TX megabytes
  puts `sudo lxc-info -n #{container.name} | grep "TX" | awk '{ print $3 }'`
end

def print_network_health network
  for container in (network.containers + [network.router])
    print_container_health container
  end
end

def print_network_health_for_ip ip
  filepath = `cd && pwd`.chomp + "/#{ip}_files/network_layout.txt"
  print_network_health Network.create_from_file filepath
end

def network_exists? ip
  filepath = `cd && pwd`.chomp + "/#{ip}_files/network_layout.txt"
  puts (File.exists?(filepath) ? "YES" : "NO")
end


