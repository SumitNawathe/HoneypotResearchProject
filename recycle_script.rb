#!/usr/bin/ruby

require 'rufus-scheduler'
require './network'
require './ssh_key_utils'
require './mitm'
require './data_utils'
require './nat_rules'

# param: ip address
if ARGV.length != 1
  puts "Usage: #{$0} [external ip address]"
  exit(1)
end
EXTERNAL_IP = ARGV[0]

# get relevant directories
HOME_DIR = `cd && pwd`.chomp
HONEYPOT_DIR = "#{HOME_DIR}/#{EXTERNAL_IP}_files"
`mkdir #{HONEYPOT_DIR}`

# create network
network_size = [5, 10].sample
n = Network.create_fresh(network_size, "prefix")
n.create_and_start_all
n.write_to_file "#{HONEYPOT_DIR}/network_layout.txt"
puts "== LOG == created network"
sleep(5)

# create MITM
port = MITM.get_port_from_external_ip(EXTERNAL_IP)
mitm = MITM.new(n, port)
puts "== LOG == created mitm"
sleep(3)

# connect MITM to router container and external IP
initialize_ssh(n.router, "password")
sleep(3)
mitm.start("#{HONEYPOT_DIR}/mitm.log")
sleep(3)
mitm.connect_to_external_ip(EXTERNAL_IP)
sleep(3)
puts "== LOG == started mitm, connected to external ip"

# container ssh linking
n.containers.each_with_index do |container, index|
  initialize_ssh(container)
  place_public_key(n.router, container)
  add_alias(n.router, container, "machine#{index}")
  puts "== LOG == connected container #{index} to router"
end

# create log files
n.redirect_auth_logs_to HONEYPOT_DIR
puts "== LOG == auth log files redirected"
puts "== LOG == ready to accept attackers"

# wait until attacker enters
`sudo chmod a+r #{HONEYPOT_DIR}/mitm.log`
`sudo tail -n 0 -f "#{HONEYPOT_DIR}/mitm.log" | grep -Eq "uthenticated"`
puts "== LOG == attacker entered"

# create timer to destroy honeypot
scheduler = Rufus::Scheduler.new
scheduler.in '1m' do
  # disconnect mitm (kick attacker out)
  mitm.disconnect_from_external_ip(EXTERNAL_IP)
  mitm.stop
  puts "=== LOG === mitm stopped"

  # retrieve and package logs/data
  package_honeypot_data(EXTERNAL_IP)
  clear_honeypot_dir(EXTERNAL_IP)
  puts "=== LOG === logs retrieved"

  # stop honeypot containers
  n.stop_and_destroy_all
  puts "== LOG == honeypot destroyed"

  # TODO: call recycle script again
  
  exit(0)
end
scheduler.join


