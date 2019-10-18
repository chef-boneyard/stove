# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stove/version'

Gem::Specification.new do |spec|
  spec.name          = 'stove'
  spec.version       = Stove::VERSION
  spec.authors       = ['Seth Vargo', 'Tim Smith']
  spec.email         = ['sethvargo@gmail.com', 'tsmith84@gmail.com']
  spec.description   = "A utility for releasing Chef Infra cookbooks"
  spec.summary       = "A command-line utility for releasing Chef community cookbooks"
  spec.homepage      = 'https://github.com/chef/stove'
  spec.license       = 'Apache-2.0'

  spec.files         = %w{LICENSE} + Dir.glob("{lib,bin,templates}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  spec.bindir        = 'bin'
  spec.executables   = 'stove'
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  # Runtime dependencies
  spec.add_dependency 'chef-infra-api', '~> 0.5'
  spec.add_dependency 'logify',   '~> 0.2'

  spec.add_development_dependency 'aruba',          '~> 0.6.0'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'community-zero', '~> 2.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec',          '~> 3.0'
  spec.add_development_dependency 'rspec-command',  '~> 1.0'
  spec.add_development_dependency 'webmock',        '~> 3.0'
end
