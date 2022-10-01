require './container.rb'
require './network.rb'

FILENAME=$1
scheduler = Rufus::Scheduler.new

scheduler.in '20m' do

	# Insert code for retrieving logs and attacker information before starting the destruction of the network HERE:	


	# Begin destruction of network:
	# Create a network object, then call network methods:


	network = Network.create_from_file($FILENAME)
	network.stop_and_destroy_all()
	puts "Network's containers have been stopped and destroyed."

end	
	

	# Call the recycle script HERE:
