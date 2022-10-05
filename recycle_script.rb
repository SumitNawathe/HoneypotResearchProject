require 'rufus-scheduler'
require './network'
require './ssh_key_utils'
require './mitm'

# param: ip address
# randomize network creation

# create network
# TODO: must be randomized
n = Network.create_fresh(3, "prefix") # TODO hardcoded
n.create_and_start_all
puts "== LOG == created network"
sleep(5)

# create MITM
external_ip = "128.8.238.197" # TODO hardcoded
port = MITM.get_port_from_external_ip(external_ip)
mitm = MITM.new(n, port)
puts "== LOG == created mitm"
sleep(3)

# connect MITM to router container and external IP
initialize_ssh(n.router, "password")
sleep(3)
mitm.start("~/mitm.log") # TODO hardcoded
sleep(3)
mitm.connect_to_external_ip(external_ip)
sleep(3)
puts "== LOG == started mitm, connected to external ip"

# container ssh linking
n.containers.each_with_index do |container, index|
  initialize_ssh(container)
  place_public_key(n.router, container)
  add_alias(n.router, container, "machine#{index}")
  puts "== LOG == connected container #{index} to router"
end

# container NAT stuff
# TODO

# wait until attacker enters
home_directory = `cd && pwd`.chomp
`sudo chmod a+r #{home_directory}/mitm.log`
`sudo tail -n 0 -f "#{home_directory}/mitm.log" | grep -Eq "uthenticated"`
puts "== LOG == attacker entered"

# create timer to destroy honeypot
scheduler = Rufus::Scheduler.new
scheduler.in '1m' do
  # TODO: retrieve logs and attacker information before destroying

  mitm.disconnect_from_external_ip(external_ip)
  mitm.stop
  # `rm -f ~/mitm.log`
  n.stop_and_destroy_all
  puts "== LOG == honeypot destroyed"

  # TODO: call recycle script again
  
  exit(0)
end
scheduler.join


