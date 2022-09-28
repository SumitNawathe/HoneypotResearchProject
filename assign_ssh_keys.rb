#!/bin/env ruby

require './network'

#if ARGV.length != 1
  #puts "Require parameter: file with serialized honeypot"
  #exit
#end

#filename = ARGV[0]
#network = Network.create_from_file(filename)

def initialize_ssh container
  `sudo lxc-attach -n "#{container.name}" -- bash -c "sudo apt-get -y install openssh-server"`
  `sudo lxc-attach -n "#{container.name}" -- bash -c "cd && ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1"`
  `sudo lxc-attach -n "#{container.name}" -- bash -c "echo \\"PermitRootLogin yes\\" >> /etc/ssh/sshd_config"`
  `sudo lxc-attach -n "#{container.name}" -- bash -c "echo \\"PasswordAuthentication no\\" >> /etc/ssh/sshd_config"`
  `sudo lxc-attach -n "#{container.name}" -- bash -c "echo \\"PubkeyAuthentication yes\\" >> /etc/ssh/sshd_config"`
  `sudo lxc-attach -n "#{container.name}" -- bash -c "sudo service ssh restart"`
end

def fetch_public_key container
  `sudo lxc-attach -n "#{container.name}" -- bash -c "cd ~/.ssh && cat id_rsa.pub"`
end

def fetch_private_key container
  `sudo lxc-attach -n "#{container.name}" -- bash -c "cd ~/.ssh && cat id_rsa"`
end

def place_public_key client, host
  client_public_key = fetch_public_key client
  `sudo lxc-attach -n "#{host.name}" -- bash -c "echo \\"#{client_public_key}\\" >> ~/.ssh/authorized_keys"`
end

def add_known_host client, host
  `sudo lxc-attach -n "#{client.name}" -- bash -c "ssh -o StrictHostKeyChecking=no root@#{host.ip} ls"`
end

