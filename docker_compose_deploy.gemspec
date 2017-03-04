# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docker_compose_deploy/version'

Gem::Specification.new do |spec|
  spec.name          = "docker_compose_deploy"
  spec.version       = DockerComposeDeploy::VERSION
  spec.authors       = ["Pete Kinnecom"]
  spec.email         = ["rubygems@k7u7.com"]
  spec.licenses    = ['MIT']

  spec.summary       = %q{This helps you deploy a website using docker-compose}
  spec.homepage      = "http://www.petekinnecom.net"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
