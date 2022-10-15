#!/usr/bin/ruby

require './container'
require './ssh_key_utils'

for i in 0...5
  # create container
  c = Container.new("healthcare#{i}")
  c.create.start

  # initialize ssh to allow file transfer
  initialize_ssh(c)

  # perform honey creation
  c.create_honey 'honey_healthcare.sh'

  # create snapshot
  c.stop
  `sudo lxc-snapshot -n #{c.name}`
end



