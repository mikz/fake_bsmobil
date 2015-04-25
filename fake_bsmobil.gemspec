# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fake_bsmobil/version'

Gem::Specification.new do |spec|
  spec.name          = "fake_bsmobil"
  spec.version       = FakeBsmobil::VERSION
  spec.authors       = ["Michal Cichra"]
  spec.email         = ["michal@o2h.cz"]

  spec.summary       = %q{Ruby server faking Bank Sabadell mobile API}
  spec.description   = %q{Ruby API faking Bank Sabadell API. Useful for testing clients.}
  spec.homepage      = "https://github.com/mikz/fake_bsmobil"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rack-test'

  spec.add_runtime_dependency 'roda', '~> 2.1'
  spec.add_runtime_dependency 'json-schema'
  spec.add_runtime_dependency 'faker'
end
