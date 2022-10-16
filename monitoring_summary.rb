#!/usr/bin/ruby

require './container'
require './network'

# state current time
puts "Current time: " + `date +%s`.chomp
puts "====================\n"

# get list of IP addresses
HOME_DIR = `cd && pwd`.chomp
ip_list = File.open("./ip_to_mitm_port.txt").readlines.map { |l| l.chomp.split[0] }

for ip in ip_list
  puts "External IP: #{ip}"
  if File.exists?(HOME_DIR + "/#{ip}_files/network_layout.txt")
    # network file exists, honeypot active
    n = Network.create_from_file(HOME_DIR + "/#{ip}_files/network_layout.txt")
    ([n.router] + n.containers).each do |c|
      puts "#{c.name}: \t#{c.running? ? "running" : "NOT RUNNING"}"
    end
  else
    # network file doesn't exist, honeypot inactive
    puts "HONEYPOT INACTIVE"
  end
  puts "Last line of log file: #{`cat ~/#{ip}.log | tail -1`.chomp}"
  puts "===================="
end

# check number of each type of attack
puts "Number of attack for each size honeypot:"
folders = `cd && ls | grep "size_.*_data"`.chomp.split
for folder in folders
  folder =~ /size_(.*)_data/
  count = `cd && ls #{folder} | grep .*.tar.gz | wc -l`.chomp
  puts "size #{$1}\t\t=>\t#{count} attacks"
end


