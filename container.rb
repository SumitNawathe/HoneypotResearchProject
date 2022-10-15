
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

  def run command
    if running?
      `sudo lxc-attach -n "#{@name}" -- bash -c "#{command}"`
    end
  end

  def root_fs
    "/var/lib/lxc/#{@name}/rootfs"
  end

  def auth_log_file
    "#{root_fs}/var/log/auth.log"
  end

  def redirect_auth_log_to output_file
    `./background_tail.sh #{auth_log_file} #{output_file}`
  end

  def create_honey honey_script_name
    # assumes ssh connection with password "password" to container
    # assumes file "./#{honey_script_name}" exist
    `sshpass -p "password" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ./#{honey_script_name} root@#{ip}:~`
    run "cd && bash ./#{honey_script_name}"
  end

private
  def lxc_info
    if @name then `sudo lxc-info -n "#{@name}"` else "" end
  end
end


