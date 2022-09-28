require './container'

class Network
  attr_accessor :size, :containers, :router

  def self.create_from_file filename
    this = nil
    File.open(filename) do |file|
      size = file.readline.split[1]
      this = self.new(size)
      this.router = Container.new(file.readline.split[1])
      
      file.each_line do |line|
        this.containers << Container.new(line.split[1])
      end
    end
    this
  end

  def self.create_fresh size, prefix
    this = self.new(size)
    this.containers = (0...size).map { |n| Container.new("#{prefix}-container-#{n}") }
    this.router = Container.new("#{prefix}-router")
    this
  end

  def write_to_file filename
    File.open(filename, 'w') do |file|
      file.write("SIZE #{@size}\n")
      file.write("ROUTER #{@router.name}\n")
      @containers.each do |container|
        file.write("CONTAINER #{container.name}\n")
      end
    end
  end

private
  def initialize size
    @size = size.to_i
    @containers = []
    @router = nil
  end
end


