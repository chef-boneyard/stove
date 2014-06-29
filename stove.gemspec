# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stove/version'

Gem::Specification.new do |spec|
  spec.name          = 'stove'
  spec.version       = Stove::VERSION
  spec.authors       = ['Seth Vargo']
  spec.email         = ['sethvargo@gmail.com']
  spec.description   = %q|A simple gem for packaging, releasing, and sanity-checking a community cookbook|
  spec.summary       = %q|A simple gem for packaging, releasing, and sanity-checking an Opscode community cookbook. This gem automatically packages the appropiate files, syncs with JIRA issues (if applicable), and automatically generates CHANGELOGs.|
  spec.homepage      = 'https://github.com/sethvargo/stove'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9'

  # Runtime dependencies
  spec.add_dependency 'faraday',               '~> 0.8.9'
  spec.add_dependency 'faraday_middleware',    '~> 0.9.0'

  spec.add_dependency 'logify',                '~> 0.2'
  spec.add_dependency 'minitar',               '~> 0.5'
  spec.add_dependency 'mixlib-authentication', '~> 1.3'
  spec.add_dependency 'octokit',               '~> 3.0'
  spec.add_dependency 'solve',                 '~> 1.2'

  spec.add_development_dependency 'aruba',          '~> 0.5'
  spec.add_development_dependency 'bundler',        '~> 1.3'
  spec.add_development_dependency 'community-zero', '~> 2.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec',          '~> 2.14'
end
