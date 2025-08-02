require "forwardable"

module Bundleup
  class CLI
    Error = Class.new(StandardError)

    include Colors
    extend Forwardable

    def_delegators :Bundleup, :commands, :logger

    attr_reader :updated_gems, :pinned_gems

    def initialize(args)
      @args = args.dup
      @update_gemfile = @args.delete("--update-gemfile")
      @updated_gems = []
      @pinned_gems = []
    end

    def run # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      print_usage && return if args.intersect?(%w[-h --help])

      @updated_gems = []
      @pinned_gems = []

      assert_gemfile_and_lock_exist!

      logger.puts "Please wait a moment while I upgrade your Gemfile.lock..."
      Backup.restore_on_error("Gemfile", "Gemfile.lock") do |backup|
        perform_analysis_and_optionally_bump_gemfile_versions do |update_report, pin_report|
          if update_report.empty?
            logger.ok "Nothing to update."
            logger.puts "\n#{pin_report}" unless pin_report.empty?
            break
          end

          logger.puts
          logger.puts update_report
          logger.puts pin_report unless pin_report.empty?

          if logger.confirm?("Do you want to apply these changes?")
            @updated_gems = update_report.updated_gems
            @pinned_gems = pin_report.pinned_gems

            logger.ok "Done!"
          else
            backup.restore
            logger.puts "Your original Gemfile.lock has been restored."
          end
        end
      end
    end

    private

    attr_reader :args

    def print_usage # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      logger.puts(<<~USAGE.gsub(/^/, "  "))

        Usage: #{green('bundleup')} #{yellow('[GEMS...] [OPTIONS]')}

        Use #{blue('bundleup')} in place of #{blue('bundle update')} to interactively update your project
        Gemfile.lock to the latest gem versions. Bundleup will show what gems will
        be updated, color-code them based on semver, and ask you to confirm the
        updates before finalizing them. For example:

            The following gems will be updated:

            #{yellow('bundler-audit 0.6.1   → 0.7.0.1')}
            i18n          1.8.2   → 1.8.5
            #{red('json          2.2.0   → (removed)')}
            parser        2.7.1.1 → 2.7.1.4
            #{red('rails         e063bef → 57a4ead')}
            #{blue('rubocop-ast   (new)   → 0.3.0')}
            #{red('thor          0.20.3  → 1.0.1')}
            #{yellow('zeitwerk      2.3.0   → 2.4.0')}

            #{yellow('Do you want to apply these changes [Yn]?')}

        Bundleup will also let you know if there are gems that can't be updated
        because they are pinned in the Gemfile. Any relevant comments from the
        Gemfile will also be included, explaining the pins:

            Note that the following gems are being held back:

            rake    12.3.3 → 13.0.1 : pinned at ~> 12.0   #{gray('# Not ready for 13 yet')}
            rubocop 0.89.0 → 0.89.1 : pinned at  = 0.89.0

        You may optionally specify one or more #{yellow('GEMS')} or pass #{yellow('OPTIONS')} to bundleup;
        these will be passed through to bundler. See #{blue('bundle update --help')} for the
        full list of the options that bundler supports.

        Finally, bundleup also supports an experimental #{yellow('--update-gemfile')} option.
        If specified, bundleup with modify the version restrictions specified in
        your Gemfile so that it can install the latest version of each gem. For
        instance, if your Gemfile specifies #{yellow('gem "sidekiq", "~> 5.2"')} but an update
        to version 6.1.2 is available, bundleup will modify the Gemfile entry to
        be #{yellow('gem "sidekiq", "~> 6.1"')} in order to permit the update.

        Examples:

            #{gray('# Update all gems')}
            #{blue('$ bundleup')}

            #{gray('# Only update gems in the development group')}
            #{blue('$ bundleup --group=development')}

            #{gray('# Only update the rake gem')}
            #{blue('$ bundleup rake')}

            #{gray('# Experimental: modify Gemfile to allow the latest gem versions')}
            #{blue('$ bundleup --update-gemfile')}

      USAGE
      true
    end

    def assert_gemfile_and_lock_exist!
      return if File.exist?("Gemfile") && File.exist?("Gemfile.lock")

      raise Error, "Gemfile and Gemfile.lock must both be present."
    end

    def perform_analysis_and_optionally_bump_gemfile_versions # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      gemfile = Gemfile.new
      lockfile_backup = Backup.new("Gemfile.lock")
      update_report, pin_report, _, outdated_gems = perform_analysis
      updatable_gems = gemfile.gem_pins_without_comments.slice(*outdated_gems.keys)

      if updatable_gems.any? && @update_gemfile
        lockfile_backup.restore
        orig_gemfile = Gemfile.new
        gemfile.relax_gem_pins!(updatable_gems.keys)
        update_report, pin_report, new_versions, = perform_analysis
        orig_gemfile.shift_gem_pins!(new_versions.slice(*updatable_gems.keys))
        commands.install
      end

      logger.clear_line
      yield(update_report, pin_report)
    end

    def perform_analysis # rubocop:disable Metrics/AbcSize
      gem_comments = Gemfile.new.gem_comments
      commands.check? || commands.install
      old_versions = commands.list
      commands.update(args)
      new_versions = commands.list
      outdated_gems = commands.outdated

      update_report = UpdateReport.new(old_versions:, new_versions:)
      pin_report = PinReport.new(gem_versions: new_versions, outdated_gems:, gem_comments:)

      [update_report, pin_report, new_versions, outdated_gems]
    end
  end
end
