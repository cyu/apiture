# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apiture/version'

Gem::Specification.new do |spec|
  spec.name          = "arch"
  spec.version       = Apiture::VERSION
  spec.authors       = ["Calvin Yu"]
  spec.email         = ["me@sourcebender.com"]
  spec.description   = %q{Create clients for REST APIs from their Swagger specification }
  spec.summary       = %q{}
  spec.homepage      = "http://github.com/cyu/apiture"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11.0"
  spec.add_development_dependency "rake", "~> 11.1.0"
  spec.add_development_dependency "rspec", "~> 3.4.0"
  spec.add_development_dependency "vcr", "~> 2.9.0"
  spec.add_development_dependency "webmock", "~> 1.20.0"

  spec.add_dependency "faraday", "~> 0.9.0"
  spec.add_dependency "faraday_middleware", "~> 0.10.0"
  spec.add_dependency "multi_json", "~> 1.3"
end
