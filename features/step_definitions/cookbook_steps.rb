Given /^I have a cookbook named "([\w\-]+)" at version "([\d\.]+)"$/ do |name, version|
  create_cookbook(name, version)
end

Given /^I have a cookbook named "([\w\-]+)"$/ do |name|
  create_cookbook(name, '0.0.0')
end

Given /^I have a cookbook named "([\w\-]+)" with git support$/ do |name|
  create_cookbook(name, '0.0.0', git: true)
end


#
# Create a new cookbook with the given name and version.
#
# @param [String] name
# @param [String] version (default: 0.0.0.0)
# @param [Hash] options
#
def create_cookbook(name, version, options = {})
  create_dir(name)
  cd(name)

  write_file('CHANGELOG.md', <<-EOH.gsub(/^ {4}/, ''))
    #{name} Changelog
    =================

    v#{version} (#{Time.now.to_date})
    ----------------------------
    - This is an entry
    - This is another entry
  EOH

  write_file('README.md', <<-EOH.gsub(/^ {4}/, ''))
    This is the README for #{name}
  EOH

  write_file('metadata.rb', <<-EOH.gsub(/^ {4}/, ''))
    name    '#{name}'
    version '#{version}'
  EOH

  if options[:git]
    git_init(current_dir)
  end
end
