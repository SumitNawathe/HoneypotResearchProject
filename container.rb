
class Container
  attr_accessor :name

  def initialize name=nil
    @name = name
  end

  def running?
    (lxc_info =~ /RUNNING/) != nil
  end

  def ip
    if running?
      `echo "#{lxc_info}" | grep "IP"`.split[1]
    end
  end

private
  def lxc_info
    @name ? `sudo lxc-info -n "#{@name}"` : ""
  end
end


