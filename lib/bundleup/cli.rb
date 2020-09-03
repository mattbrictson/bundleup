require "forwardable"

module Bundleup
  class CLI
    Error = Class.new(StandardError)

    include Colors
    extend Forwardable
    def_delegators :Bundleup, :commands, :logger

    def initialize(args)
      @args = args
    end

    def run # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      print_usage && return if (args & %w[-h --help]).any?

      assert_gemfile_and_lock_exist!

      logger.puts "Please wait a moment while I upgrade your Gemfile.lock..."
      Backup.restore_on_error("Gemfile.lock") do |backup|
        update_report, pin_report = perform_analysis

        if update_report.empty?
          logger.ok "Nothing to update."
          logger.puts "\n#{pin_report}" unless pin_report.empty?
          break
        end

        logger.puts
        logger.puts update_report
        logger.puts pin_report unless pin_report.empty?

        if logger.confirm?("Do you want to apply these changes?")
          logger.ok "Done!"
        else
          backup.restore
          logger.puts "Your original Gemfile.lock has been restored."
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

        Examples:

            #{gray('# Update all gems')}
            #{blue('$ bundleup')}

            #{gray('# Only update gems in the development group')}
            #{blue('$ bundleup --group=development')}

            #{gray('# Only update the rake gem')}
            #{blue('$ bundleup rake')}

      USAGE
      true
    end

    def assert_gemfile_and_lock_exist!
      return if File.exist?("Gemfile") && File.exist?("Gemfile.lock")

      raise Error, "Gemfile and Gemfile.lock must both be present."
    end

    def perform_analysis # rubocop:disable Metrics/AbcSize
      gem_comments = Gemfile.new.gem_comments
      commands.check? || commands.install
      old_versions = commands.list
      commands.update(args)
      new_versions = commands.list
      outdated_gems = commands.outdated

      logger.clear_line

      update_report = UpdateReport.new(old_versions: old_versions, new_versions: new_versions)
      pin_report = PinReport.new(gem_versions: new_versions, outdated_gems: outdated_gems, gem_comments: gem_comments)

      [update_report, pin_report]
    end
  end
end
