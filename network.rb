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

  def create_and_start_all
    containers_and_router.each do |container|
      container.create
      container.start
    end
  end

  def create_and_start_all_with_random_honey logger=nil
    @router.create.start
    @containers.each_with_index do |container, index|
      case [0, 1].sample
      when 0 # healthcare
        honeytype = "healthcare"
        num = [0, 1].sample # which snapshot; hardcoded
      when 1 # financial
        honeytype = "financial"
        num = [0, 1, 2].sample # which snapshot; hardcoded
      end

      container.create_from_snapshot "#{honeytype}#{num}"
      container.start
      logger.log "container #{index} has #{honeytype} honey" if logger
    end
  end

  def stop_and_destroy_all
    containers_and_router.each do |container|
      container.stop
      container.destroy
    end
  end

  def redirect_auth_logs_to directory
    `mkdir #{directory}`
    containers_and_router.each do |container|
      outfilename = "#{directory}/#{container.name}.log"
      container.redirect_auth_log_to outfilename
    end
  end

private
  def initialize size
    @size = size.to_i
    @containers = []
    @router = nil
  end

  def containers_and_router
    @containers + [@router]
  end
end


