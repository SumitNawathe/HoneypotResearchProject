# ROUGH OUTLINE

require 'rufus-scheduler'
require './network'
require './ssh_key_utils'
require './mitm'

# param: ip address
# randomize network creation

# create network
# TODO: must be randomized
n = Network.create_fresh(3, "prefix")
n.create_and_start_all
puts "== LOG == created network"
sleep(5)

# create MITM
external_ip = "128.8.238.197"
port = MITM.get_port_from_external_ip(external_ip)
puts "== LOG == port=#{port}"
mitm = MITM.new(n, port)
puts "== LOG == created mitm"
sleep(3)

# connect MITM to router container and external IP
initialize_ssh(n.router, "password")
sleep(3)
mitm.start("~/mitm.log")
sleep(3)
mitm.connect_to_external_ip(external_ip)
sleep(3)
puts "== LOG == started mitm, connected to external ip"

# container ssh linking
n.containers.each_with_index do |container, index|
  initialize_ssh(container)
  puts "== LOG == initialize container #{index} ssh"
  place_public_key(n.router, container)
  puts "== LOG == placed public key for container #{index}"
  add_alias(n.router, container, "machine#{index}")
  puts "== LOG == added alias for container #{index} to router"
end

# container NAT stuff

# 20 min timer after attacker enters
scheduler = Rufus::Scheduler.new
scheduler.in '1m' do
  # TODO: retrieve logs and attacker information before destroying

  n.stop_and_destroy_all
  mitm.disconnect_from_external_ip(external_ip)
  mitm.stop
  puts "Network's containers have been stopped and destroyed"

  # TODO: call recycle script again
end
scheduler.join

puts "Done"

