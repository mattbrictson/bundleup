module Bundleup
  class Upgrade
    def initialize(update_args=[], commands=BundleCommands.new)
      @update_args = update_args
      @commands = commands
      @gem_statuses = {}
      @original_lockfile_contents = IO.read(lockfile)
      run
    end

    def upgrades
      @gem_statuses.values.select(&:upgraded?).sort_by(&:name)
    end

    def pins
      @gem_statuses.values.select(&:pinned?).sort_by(&:name)
    end

    def lockfile_changed?
      IO.read(lockfile) != original_lockfile_contents
    end

    def undo
      IO.write(lockfile, original_lockfile_contents)
    end

    private

    attr_reader :update_args, :commands, :original_lockfile_contents

    def run
      find_versions(:old)
      commands.update(update_args)
      find_versions(:new)
      find_pinned_versions
    end

    def lockfile
      "Gemfile.lock"
    end

    def find_pinned_versions
      OutdatedParser.parse(commands.outdated).each do |gem|
        gem_status(gem[:name]).newest_version = gem[:newest]
        gem_status(gem[:name]).pin = gem[:pin]
      end
    end

    def find_versions(type)
      commands.list.scan(/\* (\S+) \((\S+)(?: (\S+))?\)/) do |name, ver, sha|
        gem_status(name).public_send("#{type}_version=", sha || ver)
      end
    end

    def gem_status(name)
      @gem_statuses[name] ||= GemStatus.new(name)
    end
  end
end
