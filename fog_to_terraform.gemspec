# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fog_to_terraform/version'

Gem::Specification.new do |spec|
  spec.name          = "fog_to_terraform"
  spec.version       = FogToTerraform::VERSION
  spec.authors       = ["Dr Nic Williams"]
  spec.email         = ["drnicwilliams@gmail.com"]
  spec.summary       = %q{Creates a `terraform.tfvars` input variable file for terraform plans using credentials from a fog-formatted YAML file.}
  spec.description   = %q{Creates a `terraform.tfvars` input variable file for terraform plans using credentials from a fog-formatted YAML file.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cyoi", "~> 0.11"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
