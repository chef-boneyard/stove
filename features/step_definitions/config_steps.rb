Given /^the Stove config is empty$/ do
  path = File.join(tmp_path, '_config.rb')

  write_file(path, '{}')
  set_env('STOVE_CONFIG', path)
end

Given /^the Stove config at "(.+)" is "(.*)"$/ do |path, value|
  parts   = path.split('.').map(&:to_sym)
  parents = parts[0...-1]

  path = ENV['STOVE_CONFIG']
  config = JSON.parse(File.read(path), symbolize_names: true)

  # Vivify the hash
  parent = parents.inject(config) do |config, parent|
    config[parent] ||= {}
    config[parent]
  end

  parent[parts.last] = value

  File.open(path, 'w') { |f| f.write(JSON.generate(config)) }
end
