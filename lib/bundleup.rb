require "bundleup/version"
require "bundleup/backup"
require "bundleup/colors"
require "bundleup/cli"
require "bundleup/commands"
require "bundleup/gemfile"
require "bundleup/logger"
require "bundleup/report"
require "bundleup/shell"
require "bundleup/pin_report"
require "bundleup/update_report"
require "bundleup/version_spec"

module Bundleup
  class << self
    attr_accessor :commands, :logger, :shell
  end
end

Bundleup.commands = Bundleup::Commands.new
Bundleup.logger = Bundleup::Logger.new
Bundleup.shell = Bundleup::Shell.new
