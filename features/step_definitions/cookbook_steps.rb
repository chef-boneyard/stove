Given /^I have a cookbook named "(.+)"(?: (?:at|with) version "(.+)")?$/ do |name, version|
  create_cookbook(name, version)
end

Given /^I have a cookbook named "(.+)"(?: (?:at|with) version "(.+)")? with git support$/ do |name, version|
  create_cookbook(name, version, git: true)
end


# Create a new cookbook with the given name and version.
#
# @param [String] name
# @param [String] version (default: 0.0.0.0)
# @param [Hash] options
def create_cookbook(name, version, options = {})
  create_dir(name)
  cd(name)
  write_file('CHANGELOG.md', "#{name} Cookbook CHANGELOG\n=====\n\nv0.0.0\n-----")
  write_file('README.md', 'This is a README')
  write_file('metadata.rb', "name '#{name}'\nversion '#{version || '0.0.0'}'")

  if options[:git]
    git_init(current_dir)
  end
end
