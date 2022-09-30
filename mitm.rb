
class MITM
  attr_accessor :network, :port

  def initialize network, port
    @network = network
    @port = port
  end

  def start logfile
    `sudo forever -l #{logfile} start ~/MITM/mitm.js -n #{network.router.name} -i #{network.router.ip} -p #{@port} --auto-access --auto-access-fixed 2 --debug`
  end

  def stop
    forever_line = `sudo forever list | grep "10.0.3.141"`
    return if forever == ""
    forever_num = forever_line.match(/.*\[([0-9])\].*/)[1]
    `sudo forever stop #{forever_num}`
  end

  def connect_to_external_ip external_ip
    # add external ip to interface
    `sudo ip addr add #{external_ip}/24 brd + dev enp4s2`
    `sudo ip link set dev enp4s2 up`
    `sudo sysctl -w net.ipv4.ip_forwarded=1`

    # add NAT rules
    `sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination #{external_ip} --jump DNAT --to-destination #{network.router.ip}`
    `sudo iptables --table nat --insert POSTROUTING --source #{network.router.ip} --destination 0.0.0.0/0 --jump SNAT --to-source #{external_ip}`
  end

  def disconnect_from_external_ip external_ip
    # remove NAT rules
    `sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination #{external_ip} --jump DNAT --to-destination #{network.router.ip}`
    `sudo iptables --table nat --delete POSTROUTING --source #{network.router.ip} --destination 0.0.0.0/0 --jump SNAT --to-source #{external_ip}`
  end

  def self.get_port_from_external_ip external_ip
    File.open("~/ip_to_mitm_port.txt").readlines do |line|
      ip, port = line.split
      return port if ip == external_ip
    end
    nil
  end
end


