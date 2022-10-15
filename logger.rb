
class HoneypotLogger
  def initialize ip=nil
    @ip = ip
  end

  def log msg
    if @ip
      filename = `cd && pwd`.chomp + "/#{@ip}.log"
      `touch #{filename}`
      time = `date +%s`.chomp
      msg_with_time = "#{time} #{msg}"
      File.open(filename, "a") do |file|
        file.puts msg_with_time
      end
    else
      puts msg_with_time
    end
  end
end



