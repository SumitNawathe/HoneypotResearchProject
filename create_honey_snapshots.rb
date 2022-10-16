#!/usr/bin/ruby

require './container'
require './ssh_key_utils'

# for i in 0...2
  # # create container
  # c = Container.new("healthcare#{i}")
  # c.create.start
  # sleep(3)
# 
  # # initialize ssh to allow file transfer
  # initialize_ssh(c)
  # sleep(3)
# 
  # # perform honey creation
  # c.create_honey 'honey_healthcare.sh'
  # sleep(3)
# 
  # # create snapshot
  # c.stop
  # `sudo lxc-snapshot -n #{c.name}`
# end

for i in 0..2
  # create container
  c = Container.new("financial#{i}")
  c.create.start
  sleep(5)

  # initialize ssh to allow for file transfer
  initialize_ssh(c)
  sleep(5)

  # perform honey creation
  c.create_honey 'honey_financial.sh'
  sleep(5)

  # create snapshot
  c.stop
  `sudo lxc-snapshot -n #{c.name}`
end



