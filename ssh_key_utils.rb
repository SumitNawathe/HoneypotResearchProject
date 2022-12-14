#!/bin/env ruby

require './network'

#if ARGV.length != 1
  #puts "Require parameter: file with serialized honeypot"
  #exit
#end

#filename = ARGV[0]
#network = Network.create_from_file(filename)

# create ssh server, set root password as "password"
def initialize_ssh container
  container.run "sudo apt-get -y install openssh-server"
  container.run "cd && ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1"
  container.run "echo \\\"PermitRootLogin yes\\\" >> /etc/ssh/sshd_config"
  container.run "echo -e \\\"password\npassword\n\\\" | sudo passwd root"
  container.run "echo \\\"HashKnownHosts no\\\" >> /etc/ssh/ssh_config"
  container.run "sudo service ssh restart"
end

def enforce_key_login container
  container.run "echo \\\"PasswordAuthentication no\\\" >> /etc/ssh/sshd_config"
  container.run "echo \\\"PubkeyAuthentication yes\\\" >> /etc/ssh/sshd_config"
  container.run "sudo service ssh restart"
end

def fetch_public_key container
  container.run "cd ~/.ssh && cat id_rsa.pub"
end

def fetch_private_key container
  container.run "cd ~/.ssh && cat id_rsa"
end

def place_public_key client, host
  client_public_key = fetch_public_key client
  host.run "echo \\\"#{client_public_key}\\\" >> ~/.ssh/authorized_keys"
end

def add_known_host client, host
  client.run "ssh -o StrictHostKeyChecking=no root@#{host.ip} ls"
end

def add_alias client, host, aliasname
  client.run "echo \\\"Host #{aliasname}\n\tHostName #{host.ip}\n\tUser root\n\\\" >> ~/.ssh/config"
end

