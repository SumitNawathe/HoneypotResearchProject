#!/usr/bin/ruby

########################
# PROCESSING FUNCTIONS #
########################

def process_size_each(home_dir, size)
  data_path = home_dir + "size_#{size}_data/"
  data_files = `cd #{data_path} && ls`.split
  results = {}
  for file in data_files
    `cd #{data_path} && sudo tar -xzf #{file}`
    res = yield data_path, file
    key = file.split(".")[0]
    results[key] = res
    `cd #{data_path} && sudo rm *.processed *.txt *.log`
  end
  return results # hash: timestamp => produced value
end

def process_each(home_dir, &block)
  results = {}
  for size in [3, 6, 9, 12]
    results[size] = process_size_each(home_dir, size, &block)
  end
  return results # hash: size => (timestamp => produced value)
end

#####################
# UTILITY FUNCTIONS #
#####################

# MITM log line -> UNIX epoch time
def get_time(line)
  timestamp = `echo "#{line.chomp}" | awk '{print $1, $2}'`.chomp
  `date -d"#{timestamp}" +%s.%N`.chomp.to_f
end

# prints ruby dictionary of arrays in Python-readable format
def print_as_py_dict(results)
  puts "{"
  results.map { |k,v| puts "#{k}: #{v.values}," }
  puts "}"
end

#######################
# METRIC CALCULATIONS #
#######################

def calc_recycles_and_sessions(home_dir)
  results = process_each(home_dir) do |data_dir, file|
    attacker_entered = false
    num_sessions = 0
    cutoff = nil
    File.foreach(data_dir + "mitm.log").each do |line|
      attacker_entered = true if line =~ /Threshold: 2, Attempts: 2/
      next if !attacker_entered
      if line =~ /Attacker authenticated/
        cutoff = get_time(line) + 60*30 if !cutoff
        next if get_time(line) > cutoff
        num_sessions += 1
      end
    end
    num_sessions
  end
  results.map do |size, data|
    puts "#{size}: #{data.values},"
  end
end

def calc_time_recycle(home_dir)
  results = process_each(home_dir) do |data_dir, file|
    attacker_entered = false
    times = []
    last_time = nil
    cutoff = nil
    File.foreach(data_dir + "mitm.log").each do |line|
      attacker_entered = true if line =~ /Threshold: 2, Attempts: 2/
      next if !attacker_entered
      if line =~ /Attacker authenticated/
        curr_time = get_time(line)
        cutoff = curr_time + 60*30 if !cutoff
        next if curr_time > cutoff
        last_time = curr_time
      elsif last_time && line =~ /Attacker closed connection/
        times.append(get_time(line) - last_time)
        last_time = nil
      end
    end
    if last_time
      last_line = `cd #{data_dir} && cat mitm.log | tail -n 2 | head -n 1`.chomp
      final = get_time(last_line)
      times.append([cutoff, final].min - last_time)
    end
    times
  end
  results.map do |size, data|
    totals = data.map do |timestamp, times|
      times.sum
    end
    puts "#{size}: #{totals},"
  end
end

def calc_time_session(home_dir)
  results = process_each(home_dir) do |data_dir, file|
    attacker_entered = false
    times = []
    last_time = nil
    cutoff = nil
    File.foreach(data_dir + "mitm.log").each do |line|
      attacker_entered = true if line =~ /Threshold: 2, Attempts: 2/
      next if !attacker_entered
      if line =~ /Attacker authenticated/
        curr_time = get_time(line)
        cutoff = curr_time + 60*30 if !cutoff
        next if curr_time > cutoff
        last_time = curr_time
      elsif last_time && line =~ /Attacker closed connection/
        times.append(get_time(line) - last_time)
        last_time = nil
      end
    end
    if last_time
      last_line = `cd #{data_dir} && cat mitm.log | tail -n 2 | head -n 1`.chomp
      final = get_time(last_line)
      times.append([cutoff, final].min - last_time)
    end
    times
  end
  results.map do |size, data|
    lst = []
    data.map do |timestamp, times|
      lst += times
    end
    puts "#{size}: #{lst},"
  end
end

def calc_commands_recycle_split(home_dir)
  results = process_each(home_dir) do |data_dir, file|
    File.read(data_dir + "mitm_commands.processed").split(/;|\n */).length
  end
  results.map do |size, data|
    puts "#{size}: #{data.values},"
  end
end

def calc_commands_recycle_lines(home_dir)
  results = process_each("/home/sumit/") do |data_dir, file|
    File.read(data_dir + "mitm_commands.processed").split(/\n */).length
  end
  results.map do |size, data|
    puts "#{size}: #{data.values},"
  end
end

def calc_commands_session_split(home_dir)
  results = process_each("/home/sumit/") do |data_dir, file|
    attacker_entered = false
    commands = []
    curr_commands = 0
    cutoff_time = nil
    File.foreach(data_dir + "mitm.log").each do |line|
      attacker_entered = true if line =~ /Threshold: 2, Attempts: 2/
      next if !attacker_entered
      if line =~ /Attacker authenticated/
        cutoff_time = get_time(line) + 60*30 if !cutoff_time
      elsif cutoff_time && line =~ /command/
        next if get_time(line) > cutoff_time
        stripped = line.chomp.split(':')[3..].join(':')
        num = stripped.chomp.split(/;|\n */).length
        if line =~ /Noninteractive/
          commands.append num
        else
          curr_commands += num
        end
      elsif cutoff_time && line =~ /Attacker closed connection/
        commands.append(curr_commands) if curr_commands > 0
        curr_commands = 0
      end
    end
    commands.append(curr_commands) if curr_commands > 0
    commands
  end
  results.map do |size, data|
    lst = []
    for v in data.values
        lst += v
    end
    puts "#{size}: #{lst},"
  end
end

def calc_command_binning(home_dir)
  results = process_each("/home/sumit/") do |data_dir, file|
    attacker_entered = false
    commands = []
    curr_commands = []
    cutoff_time = nil
    File.foreach(data_dir + "mitm.log").each do |line|
      attacker_entered = true if line =~ /Threshold: 2, Attempts: 2/
      next if !attacker_entered
      if line =~ /Attacker authenticated/
        cutoff_time = get_time(line) + 60*30 if !cutoff_time
      elsif cutoff_time && line =~ /command/
        next if get_time(line) > cutoff_time
        curr_commands.append line.chomp
      elsif cutoff_time && line =~ /Attacker closed connection/
        commands.append(curr_commands) if curr_commands.length > 0
        curr_commands = []
      end
    end
    commands.append(curr_commands) if curr_commands.length > 0
    commands
  end
  results.map do |size, data|
    hash = {}
    data.each do |timestamp, sessions|
      sessions.each do |session|
        session.each do |line|
          l = line.split(':')[3..].join(':').strip
          if hash.has_key?(l)
            hash[l] += 1
          else
            hash[l] = 1
          end
        end
      end
    end
    puts "#{size}: {"
    for k, v in hash
      puts "'#{k}': #{v},"
    end
    puts "},"
  end
end

