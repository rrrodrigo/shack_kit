# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shack_kit/version'

Gem::Specification.new do |spec|
  spec.name          = "shack_kit"
  spec.version       = ShackKit::VERSION
  spec.authors       = ["Marcin Bajer"]
  spec.email         = ["bajer@tigana.pl"]

  spec.summary       = "Set of HAM radio tools packaged by SQ9OZM"
  spec.description   = "Set of HAM radio tools, currently limited to SP and SOTA-related stuff"
  spec.homepage      = "https://github.com/rrrodrigo/shack_kit"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         =  Dir["{bin,db,lib}/**/*", "README.md", "LICENSE.txt", "CHANGELOG.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'irbtools', '~> 2.2'
  spec.add_runtime_dependency 'sqlite3', '~> 1.4', '>= 1.4.2'
  spec.add_runtime_dependency 'sequel', '~> 4', '>= 4.49'
  spec.add_runtime_dependency 'maidenhead', '~> 1.0', '>= 1.0.1'
  spec.add_runtime_dependency 'oga', '~> 2.15', '>= 2.15'
  spec.add_runtime_dependency 'http', '~> 2.2', '>= 2.2.2'
end
