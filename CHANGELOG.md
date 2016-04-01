# bundleup Change Log

All notable changes to this project will be documented in this file.

bundleup is in a pre-1.0 state. This means that its APIs and behavior are subject to breaking changes without deprecation notices. Until 1.0, version numbers will follow a [Semver][]-ish `0.y.z` format, where `y` is incremented when new features or breaking changes are introduced, and `z` is incremented for lesser changes or bug fixes.

## [Unreleased][]

* Your contribution here!

## [0.5.0][] (2016-04-01)

* You can now pass command-line arguments to bundleup, which will in turn be
  handed to `bundle update`. For example: `bundleup --group=development`.
* Improve the console output when a Bundler command fails.
* Fixed a bug where if a Bundler command failed to run, it would be executed a
  second time.

## [0.4.0][] (2016-02-19)

* **Change the upgrade process to modify the Gemfile.lock in place, with the
  option to "undo" (i.e. restore from backup) if the changes are not desired.**
  This makes bundleup much faster since it doesn't have to run `bundle update`
  twice.
* Fixed a bug where color was mistakenly based on the newest version of a gem,
  even if a restriction prevented upgrading to that version.

## [0.3.0][] (2016-01-08)

* Always show SHA changes in red. If a dependency is tracking a
  Git branch, and running `bundle update` would cause that branch
  to updated and point to a new ref, that is something that
  warrants attention.

## [0.2.0][] (2015-12-26)

* Animated spinner during long-running bundler commands
* Rather than run `bundle` in a temp directory, run within the current
  directory, making a backup copy of Gemfile.lock. This ensures that relative
  paths and `.bundle/config` are honored.

## 0.1.0 (2015-12-24)

* Initial release

[Semver]: http://semver.org
[Unreleased]: https://github.com/mattbrictson/bundleup/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/mattbrictson/bundleup/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/mattbrictson/bundleup/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/mattbrictson/bundleup/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/mattbrictson/bundleup/compare/v0.1.0...v0.2.0
