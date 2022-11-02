
def process_size_each(home_dir, size)
  data_path = home_dir + "size_#{size}_data/"
  data_files = `cd #{data_path} && ls`.split
  results = {}
  for file in data_files
    `cd #{data_path} && sudo tar -xzf #{file}`
    res = yield data_path
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

=begin
EXAMPLE OF USE:

process_each("/home/sumit/") { |data_dir|
  `cd #{data_dir} && cat mitm_commands.processed`.split(/;|\n/).length
}

result.map { |k, v| v.values.sum / v.values.length }
# => [75, 75, 75, 82]
=end


