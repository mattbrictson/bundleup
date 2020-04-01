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
  spec.description   = "Use `bundleup` whenever you want to update the "\
                       "locked Gemfile dependencies of a Ruby project. It "\
                       "shows exactly what gems will be updated with color "\
                       "output that calls attention to significant semver "\
                       "changes. Bundleup will also let you know when a "\
                       'version "pin" in your Gemfile is preventing an '\
                       "update. Bundleup is a standalone tool that leverages "\
                       "standard Bundler output and does not patch code or "\
                       "use Bundler internals."
  spec.homepage      = "https://github.com/mattbrictson/bundleup"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "0.81.0"
  spec.add_development_dependency "rubocop-minitest", "0.6.2"
  spec.add_development_dependency "rubocop-performance", "1.5.2"
end
