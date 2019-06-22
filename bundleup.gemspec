# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bundleup/version"

Gem::Specification.new do |spec|
  spec.name          = "bundleup"
  spec.version       = Bundleup::VERSION
  spec.authors       = ["Matt Brictson"]
  spec.email         = ["bundleup@mattbrictson.com"]

  spec.summary       = "A friendlier command-line interface for Bundler’s "\
                       "`update` and `outdated` commands."
  spec.homepage      = "https://github.com/mattbrictson/bundleup"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "coveralls", "~> 0.8.19"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.1"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rubocop", "0.71.0"
end
