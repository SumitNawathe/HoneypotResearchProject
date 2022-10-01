# ROUGH OUTLINE

require './network'
require './ssh_key_utils'
require './mitm'

# param: ip address
# randomize network creation

# create network
# TODO: must be randomized
n = Network.create_fresh(3, "prefix")
n.create_and_start_all

# create MITM
external_ip = "128.8.238.197"
port = MITM.get_port_from_external_ip(external_ip)
mitm = MITM.new(n, port)

# connect MITM to router container and external IP
initialize_ssh(n.router, "password")
mitm.start("~/mitm.log")
mitm.connect_to_external_ip(external_ip)

# container ssh linking
n.containers.each_with_index do |container, index|
  initialize_ssh(container)
  place_public_key(n.router, container)
  add_alias(n.router, container, "machine#{index}")
end

# container NAT stuff

# wait for attacker to enter
# 20 min timer

mitm.disconnect_from_external_ip(external_ip)
mitm.stop
network.stop_and_destroy_all

# call script again
