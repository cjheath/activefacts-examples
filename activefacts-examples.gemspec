# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "activefacts-examples"
  spec.version       = "1.9.8"
  spec.authors       = ["Clifford Heath"]
  spec.email         = ["clifford.heath@gmail.com"]

  spec.summary       = %q{Example models for use with ActiveFacts}
  spec.description   = %q{Example models in the Constellation Query Language for use with ActiveFacts}
  spec.homepage      = "http://github.com/cjheath/activefacts-examples"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3", ">= 3.3"

  spec.add_runtime_dependency "activefacts", ">= 1.8", "~> 1"
  spec.add_runtime_dependency "activefacts-metamodel", ">= 1.9.8", "~> 1"
end
