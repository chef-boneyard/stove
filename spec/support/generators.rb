require 'fileutils'

module Stove
  module RSpec
    module Generators
      def generate_cookbook(cookbook_name = 'cookbook', folder_name = cookbook_name)
        root = tmp_path.join(folder_name)

        # Structure
        FileUtils.mkdir_p(root)
        FileUtils.mkdir_p(root.join('attributes'))
        FileUtils.mkdir_p(root.join('definitions'))
        FileUtils.mkdir_p(root.join('files'))
        FileUtils.mkdir_p(root.join('files', 'default'))
        FileUtils.mkdir_p(root.join('libraries'))
        FileUtils.mkdir_p(root.join('recipes'))
        FileUtils.mkdir_p(root.join('resources'))
        FileUtils.mkdir_p(root.join('providers'))
        FileUtils.mkdir_p(root.join('templates'))
        FileUtils.mkdir_p(root.join('templates', 'default'))

        # Files
        File.open(root.join('.foodcritic'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            ~FC031 ~FC045
          EOH
        end
        File.open(root.join('metadata.rb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            name '#{cookbook_name}'
            version '1.0.0'
          EOH
        end
        File.open(root.join('README.md'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            # It's a cookbook
          EOH
        end
        File.open(root.join('CHANGELOG.md'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            It's different. Get over it.
          EOH
        end
        File.open(root.join('Berksfile'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            source 'https://supermarket.chef.io'
            metadata
          EOH
        end
        File.open(root.join('attributes', 'default.rb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            default['foo']['bar'] = 'zip'
          EOH
        end
        File.open(root.join('attributes', 'system.rb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            default['zop']['zap'] = 'zink'
          EOH
        end
        File.open(root.join('definitions', 'web_app.rb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            # Haha did you really think I would write a definition!?
          EOH
        end
        File.open(root.join('files', 'default', 'patch.txt'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            # This is a patch
          EOH
        end
        File.open(root.join('files', 'default', 'example.txt'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            This is a file with some text
          EOH
        end
        File.open(root.join('files', 'default', '.authorized_keys'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            id-rsa ABC123
          EOH
        end
        File.open(root.join('libraries', 'magic.rb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            class Chef
              class Resource
                class Monkey
                end
              end
            end
          EOH
        end
        File.open(root.join('recipes', 'default.rb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            Chef::Log.warn("If you think you're cool, you're not!")
          EOH
        end
        File.open(root.join('recipes', 'system.rb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            execute('rm -rf /')
          EOH
        end
        File.open(root.join('resources', 'thing.rb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            actions :write, :unwrite
            default_action :write
          EOH
        end
        File.open(root.join('providers', 'thing.rb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            action(:write) {}
            action(:unwrite) {}
          EOH
        end
        File.open(root.join('templates', 'default', 'example.erb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            <%= 'Do you even ERB' %>
          EOH
        end
        File.open(root.join('templates', 'default', 'another.text.erb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            # Comment?
          EOH
        end
        File.open(root.join('templates', 'default', '.env.erb'), 'wb') do |f|
          f.write <<-EOH.gsub(/^ {11}/, '')
            ENV['FOO'] = 'BAR'
          EOH
        end

        # Return the root
        root
      end
    end
  end
end
