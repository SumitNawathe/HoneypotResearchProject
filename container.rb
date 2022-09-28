
class Container
  attr_accessor :name

  def initialize name=nil
    @name = name
  end

  def exists?
    `sudo lxc-ls | grep "#{@name}"` != ""
  end

  def running?
    exists? && ((lxc_info =~ /RUNNING/) != nil)
  end

  def ip
    if running? then `echo "#{lxc_info}" | grep "IP"`.split[1] end
  end

  def create
    if !running?
      `sudo lxc-create -n "#{@name}" -t download -- -d ubuntu -r focal fossa -a amd64`
    end
    self
  end

  def start
    if !running? then `sudo lxc-start -n "#{@name}"` end
    self
  end

  def stop
    if running? then `sudo lxc-stop -n "#{name}"` end
    self
  end

  def destroy
    if !running? then `sudo lxc-destroy -n "#{name}"` end
    nil
  end

private
  def lxc_info
    if @name then `sudo lxc-info -n "#{@name}"` else "" end
  end
end


