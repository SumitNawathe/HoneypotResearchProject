#!/usr/bin/ruby

require 'rufus-scheduler'
require './network'
require './ssh_key_utils'
require './mitm'
require './data_utils'
require './nat_rules'
require './logger'

# param: ip address
if ARGV.length != 1
  puts "Usage: #{$0} [external ip address]"
  exit(1)
end
EXTERNAL_IP = ARGV[0]
logger = HoneypotLogger.new(EXTERNAL_IP)
logger.log "beginning recycling script"

# get relevant directories
HOME_DIR = `cd && pwd`.chomp
HONEYPOT_DIR = "#{HOME_DIR}/#{EXTERNAL_IP}_files"
`mkdir #{HONEYPOT_DIR}`

# create network
network_size = [2, 3].sample
n = Network.create_fresh(network_size, "prefix")
n.create_and_start_all
n.write_to_file "#{HONEYPOT_DIR}/network_layout.txt"
logger.log "created network size=#{network_size}"
sleep(5)

# create MITM
port = MITM.get_port_from_external_ip(EXTERNAL_IP)
mitm = MITM.new(n, port)
logger.log "created mitm"
sleep(3)

# connect MITM to router container and external IP
initialize_ssh(n.router)
sleep(3)
mitm.start("#{HONEYPOT_DIR}/mitm.log")
sleep(3)
logger.log "mitm started"

# container ssh setup and linking
n.containers.each_with_index do |container, index|
  initialize_ssh(container)
  place_public_key(n.router, container)
  add_alias(n.router, container, "machine#{index}")
  logger.log "connected container #{index} to router"

  honey_script_name = ['honey_healthcare.sh', 'honey_financial.sh'].sample
  container.create_honey honey_script_name
  logger.log "created honey in container #{index}"
end

# enforce key login on containers
n.containers.each do |container|
  enforce_key_login(container)
end

# create log files
n.redirect_auth_logs_to HONEYPOT_DIR
logger.log "auth log files redirected"

# connect honeypot network to external ip
mitm.connect_to_external_ip(EXTERNAL_IP)
logger.log "mitm connected to external ip"
logger.log "ready to accept attackers"

# wait until attacker enters
`sudo chmod a+r #{HONEYPOT_DIR}/mitm.log`
`sudo tail -n 0 -f "#{HONEYPOT_DIR}/mitm.log" | grep -Eq "Compromising the honeypot"`
logger.log "attacker entered"

# timer to destroy honeypot
scheduler = Rufus::Scheduler.new
scheduler.in '1m' do
  logger.log "beginning honeypot destruction"

  # disconnect mitm (kick attacker out)
  mitm.disconnect_from_external_ip(EXTERNAL_IP)
  mitm.stop
  logger.log "mitm stopped"

  # process and package logs/data
  get_duration_calculations(EXTERNAL_IP)
  get_mitm_commands(EXTERNAL_IP)
  package_honeypot_data(EXTERNAL_IP)
  clear_honeypot_dir(EXTERNAL_IP)
  logger.log "logs retrieved"

  # stop honeypot containers
  n.stop_and_destroy_all
  logger.log "honeypot destroyed"

  # TODO: call recycle script again
  
  exit(0)
end
scheduler.join


