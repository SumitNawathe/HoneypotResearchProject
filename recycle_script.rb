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
`cd #{HONEYPOT_DIR} && sudo rm -rf *`

# create network
network_size = [3, 6, 9, 12].sample
n = Network.create_fresh(network_size, "#{EXTERNAL_IP}-honeypot")
n.create_and_start_all
# n.create_and_start_all_with_random_honey
n.write_to_file "#{HONEYPOT_DIR}/network_layout.txt"
logger.log "created network size=#{network_size}"
sleep(5)

# debug: check whether containers are up
logger.log "checking whether containers are up"
([n.router] + n.containers).each do |container|
  counter = 0
  while !container.running?
    counter += 1
    logger "#{container.name} FAILED TO START; counter=#{counter}"
    container.start
    sleep([2, 4, 6, 8, 10].sample)
  end
  logger.log "#{container.name} up"
  sleep(2)

  #if container.running?
    #logger.log "#{container} up"
  #else
    #logger.log "#{container} IS NOT UP, attempting again"
    #container.start
    #sleep(2)
    #if container.running?
      #logger.log "#{container} up after second attempt"
    #else
      #logger.log "#{container} STILL NOT UP"
    #end
  #end
end

# create MITM
port = MITM.get_port_from_external_ip(EXTERNAL_IP)
mitm = MITM.new(n, port)
logger.log "created mitm: external ip #{EXTERNAL_IP}, port #{port}"
sleep(3)

# connect MITM to router container and external IP
initialize_ssh(n.router)
sleep(3)
mitm.start("#{HONEYPOT_DIR}/mitm.log")
sleep(3)
logger.log "mitm started"

n.containers.each_with_index do |container, index|
  # set up ssh keys and alias
  initialize_ssh(container)
  place_public_key(n.router, container)
  random = [*('A'..'Z'),*('0'..'9')].shuffle[0,8].join
  add_alias(n.router, container, "machine#{index}_#{random}")
  logger.log "connected container #{index} to router"

  # upload random honey
  honeytype = ["healthcare", "financial", "PII"].sample
  num = [0, 1, 2].sample
  honey_dir = `pwd`.chomp + "/honey/#{honeytype}"
  honey_filename = "#{honeytype}#{num}.tar.gz"
  container.upload_honey(honey_dir, honey_filename)
end

# add banner to router container
random = [*('A'..'Z'),*('0'..'9')].shuffle[0,16].join
n.router.run "echo \'PrintMotd yes\n\' >> /etc/ssh/sshd_config"
n.router.run "echo \'------------------------------------------------------------\nAuthorized access only!\nThis is a router machine for internal use only.\nUnique identifier: #{random}\nNumber of machines accessible by ssh: #{network_size}\nPlease contact the IT department if you need to be given permission to access the network.\n------------------------------------------------------------\n\' > /etc/motd"
n.router.run "sudo service ssh restart"
sleep(3)

# allow connections in firewall rules
allow_container_connections(n)

# enforce key login on containers
n.containers.each do |container|
  enforce_key_login(container)
end

# create log files
n.redirect_auth_logs_to HONEYPOT_DIR
logger.log "auth log files redirected"

# connect containers to internet through external IP
allow_network_internet(n, EXTERNAL_IP)

# connect honeypot network to external ip
mitm.connect_to_external_ip(EXTERNAL_IP)
logger.log "mitm connected to external ip"
logger.log "ready to accept attackers"

# wait until attacker enters
`sudo chmod a+r #{HONEYPOT_DIR}/mitm.log`
`sudo tail -n 0 -f "#{HONEYPOT_DIR}/mitm.log" | grep -Eq "Compromising the honeypot"`
logger.log "attacker entered"

# put ssh in attacker's home directory
attacker_username = `cat #{HONEYPOT_DIR}/mitm.log | grep "Adding the following credentials" | cut -d':' -f4 | colrm 1 2`.chomp
logger.log "attacker username: #{attacker_username}"
sleep(1)
n.router.run "cp -r ~/.ssh /home/#{attacker_username}/.ssh"
n.router.run "chmod a+x /home/#{attacker_username}/.ssh"
n.router.run "chmod a+r /home/#{attacker_username}/.ssh -R"
logger.log "put .ssh in attacker's home directory"

# give attacker sudo on every machine
([n.router] + n.containers).each do |container|
  logger.log "granting sudo for container #{container.name}"
  container.run "sudo adduser #{attacker_username} sudo"
  container.run "echo '#{attacker_username} ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo"
end
logger.log "attacker granted sudo access"

# timer to destroy honeypot
scheduler = Rufus::Scheduler.new
scheduler.in '30m' do
  logger.log "beginning honeypot destruction"

  # disconnect mitm (kick attacker out)
  mitm.disconnect_from_external_ip(EXTERNAL_IP)
  mitm.stop
  logger.log "mitm stopped"
  sleep(2)

  # connect containers to internet through external IP
  disallow_network_internet(n, EXTERNAL_IP)
  sleep(2)

  # disallow connections in firewall rules
  disallow_container_connections(n)
  sleep(2)

  # process and package logs/data
  get_duration_calculations(EXTERNAL_IP)
  get_mitm_commands(EXTERNAL_IP)
  package_honeypot_data(EXTERNAL_IP)
  clear_honeypot_dir(EXTERNAL_IP)
  logger.log "logs retrieved"
  sleep(1)

  # stop honeypot containers
  n.stop_and_destroy_all
  logger.log "honeypot destroyed"
  sleep(3)

  # call recycle script again
  `nohup ./recycle_script.rb #{EXTERNAL_IP} &`
  exit(0)
end
scheduler.join


