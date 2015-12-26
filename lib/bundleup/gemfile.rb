require "fileutils"
require "tmpdir"

module Bundleup
  class Gemfile
    def initialize(commands=BundleCommands.new)
      @commands = commands
      @gem_statuses = {}
      load
    end

    def upgrades
      @gem_statuses.values.select(&:upgraded?).sort_by(&:name)
    end

    def pins
      @gem_statuses.values.select(&:pinned?).sort_by(&:name)
    end

    private

    attr_reader :commands

    def load
      with_copy_of_lockfile do
        find_versions(:old)
        commands.update
        find_versions(:new)
        find_pinned_versions
      end
    end

    def with_copy_of_lockfile
      backup = ".Gemfile.lock.#{rand(1_000_000_000).to_s(36)}"
      FileUtils.cp("Gemfile.lock", backup)
      yield
    ensure
      FileUtils.mv(backup, "Gemfile.lock")
    end

    def find_pinned_versions
      expr = /\* (\S+) \(newest (\S+),.* requested (.*)\)/
      commands.outdated.scan(expr) do |name, newest, pin|
        gem_status(name).newest_version = newest
        gem_status(name).pin = pin
      end
    end

    def find_versions(type)
      commands.show.scan(/\* (\S+) \((\S+)(?: (\S+))?\)/) do |name, ver, sha|
        gem_status(name).public_send("#{type}_version=", sha || ver)
      end
    end

    def gem_status(name)
      @gem_statuses[name] ||= GemStatus.new(name)
    end
  end
end
