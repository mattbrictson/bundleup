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

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "chandler"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rubocop"
end
