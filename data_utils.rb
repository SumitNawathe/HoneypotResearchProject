require './network'

def home_dir
  `cd && pwd`.chomp
end

def get_honeypot_dir ip
  "#{home_dir}/#{ip}_files"
end

def package_honeypot_data ip
  timestamp = `date +%s`.chomp
  honeypot_dir = get_honeypot_dir(ip)
  `echo #{ip} >> #{honeypot_dir}/external_ip.txt`
  `cd #{honeypot_dir} && tar -czf #{timestamp}.tar.gz *`
  honeypot_size = Network.create_from_file("#{honeypot_dir}/network_layout.txt").size
  destination = "#{home_dir}/size_#{honeypot_size}_data"
  `mkdir #{destination}`
  `mv #{honeypot_dir}/#{timestamp}.tar.gz #{destination}`
end

def get_duration_calculations ip
  honeypot_dir = get_honeypot_dir(ip)
  network = Network.create_from_file("#{honeypot_dir}/network_layout.txt")
  `touch #{honeypot_dir}/duration.processed`
  File.open("#{honeypot_dir}/duration.processed", "a") do |file|
    file.puts "#{network.router.name} " + `./duration_calculation.sh #{honeypot_dir}/#{network.router.name}.log`.chomp
    for container in network.containers
      file.puts "#{container.name} " + `./duration_calculation.sh #{honeypot_dir}/#{container.name}.log`.chomp
    end
  end
end

def get_mitm_commands ip
  `./mitm_scrape.sh #{get_honeypot_dir(ip)}`
end

def clear_honeypot_dir ip
  `cd #{get_honeypot_dir(ip)} && rm -f *`
end

