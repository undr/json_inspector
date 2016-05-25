# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_inspector/version'

Gem::Specification.new do |spec|
  spec.name          = 'json_inspector'
  spec.version       = JsonInspector::VERSION
  spec.authors       = ['undr']
  spec.email         = ["undr@yandex.ru"]

  spec.summary       = %q{Console tool for inspecting JSON.}
  spec.description   = %q{Console tool for inspecting JSON.}
  spec.homepage      = 'https://github.com/undr/json_inspector'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']


  spec.add_dependency 'pry'
  spec.add_dependency 'hashie'
  spec.add_dependency 'multi_json'

  spec.add_development_dependency 'bundler', "~> 1.11"
  spec.add_development_dependency 'rake', "~> 10.0"
  spec.add_development_dependency 'rspec', "~> 3.0"
end
