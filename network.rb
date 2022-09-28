require './container'

class Network
  attr_accessor :size, :containers, :router

  def self.create_from_file filename
    begin
      file = File.open(filename)

      size = file.readline.split[1]
      this = self.new(size)
      this.router = Container.new(file.readline.split[1])
      
      file.each_line do |line|
        this.containers << Container.new(line.split[1])
      end

      file.close
      this
    rescue
      puts "Failed to create network from file #{filename}"
      nil
    end
  end

  def self.create_fresh size

  end

private
  def initialize size
    @size = size.to_i
    @containers = []
    @router = nil
  end
end


