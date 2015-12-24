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
      in_temp_dir do
        find_versions(:old)
        commands.update
        find_versions(:new)
        find_pinned_versions
      end
    end

    def in_temp_dir(&block)
      Dir.mktmpdir do |dir|
        FileUtils.cp("Gemfile", dir)
        FileUtils.cp("Gemfile.lock", dir)
        FileUtils.cp(Dir["*.gemspec"], dir) if Dir["*.gemspec"].any?
        FileUtils.cp_r("lib", dir) if File.directory?("lib")
        Dir.chdir(dir, &block)
      end
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
