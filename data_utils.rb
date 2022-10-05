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
  `cd #{honeypot_dir} && tar -czf #{timestamp}.tar.gz *`
  honeypot_size = Network.create_from_file("#{honeypot_dir}/network_layout.txt").size
  destination = "#{home_dir}/size_#{honeypot_size}_data"
  `mkdir #{destination}`
  `mv #{honeypot_dir}/#{timestamp}.tar.gz #{destination}`
end

def clear_honeypot_dir ip
  `cd #{get_honeypot_dir(ip)} && rm -f *`
end

