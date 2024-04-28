require_relative "lib/bundleup/version"

Gem::Specification.new do |spec|
  spec.name = "bundleup"
  spec.version = Bundleup::VERSION
  spec.authors = ["Matt Brictson"]
  spec.email = ["bundleup@mattbrictson.com"]

  spec.summary = "A friendlier command-line interface for Bundler’s `update` and `outdated` commands."
  spec.description =
    "Use `bundleup` whenever you want to update the locked Gemfile dependencies of a Ruby project. It shows exactly " \
    "what gems will be updated with color output that calls attention to significant semver changes. Bundleup will " \
    'also let you know when a version "pin" in your Gemfile is preventing an update. Bundleup is a standalone tool ' \
    "that leverages standard Bundler output and does not patch code or use Bundler internals."

  spec.homepage = "https://github.com/mattbrictson/bundleup"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/mattbrictson/bundleup/issues",
    "changelog_uri" => "https://github.com/mattbrictson/bundleup/releases",
    "source_code_uri" => "https://github.com/mattbrictson/bundleup",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[LICENSE.txt README.md {exe,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
