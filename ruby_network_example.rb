#!/bin/env ruby

require './container.rb'
require './network.rb'

# create network with 3 honeypot containers and names starting with "prefix"
n = Network.create_fresh(3, "prefix")

# print names of router and all containers
puts n.router.name
n.containers.each do |container|
  puts container.name
end

# create start router and containers
for container in (n.containers + [n.router])
  container.create
  container.start
  puts "created and started #{container.name}"
end

# check if everything is running, print IP addresses
for container in (n.containers + [n.router])
  if container.running?
    puts "#{container.name} is running, has IP #{container.ip}"
  else
    puts "#{container.name} is not running"
  end
end

# stop and destroy everything
for container in (n.containers + [n.router])
  container.stop
  container.destroy
  puts "stopped and destroyed #{container.name}"
end

puts "script end"


