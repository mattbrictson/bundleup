require "test_helper"
require "fileutils"
require "tempfile"

class Bundleup::CLITest < Minitest::Test
  include OutputHelpers

  def test_it_works_with_a_sample_project # rubocop:disable Minitest/MultipleAssertions
    stdout = within_copy_of_sample_project do
      capturing_plain_output(stdin: "n\n") do
        with_clean_bundler_env do
          Bundleup::CLI.new([]).run
        end
      end
    end
    assert_includes(stdout, "Please wait a moment while I upgrade your Gemfile.lock...")
    assert_includes(stdout, "The following gems will be updated:")
    assert_match(/^mail\s+2\.7\.0\s+→ [\d.]+\s*$/, stdout)
    assert_match(/^mocha\s+1\.11\.1\s+→ [\d.]+\s*$/, stdout)
    assert_includes(stdout, "Note that the following gems are being held back:")
    assert_match(/^rake\s+12\.3\.3\s+→ [\d.]+\s+:\s+pinned at ~> 12\.0\s+# Not ready for 13 yet\s*$/, stdout)
    assert_match(/^rubocop\s+0\.89\.0\s+→ [\d.]+\s+:\s+pinned at  = 0\.89\.0\s*$/, stdout)
    assert_includes(stdout, "Do you want to apply these changes [Yn]?")
    assert_includes(stdout, "Your original Gemfile.lock has been restored.")
  end

  def test_it_passes_args_to_bundle_update
    stdout = capturing_plain_output(stdin: "n\n") do
      Dir.chdir(File.expand_path("../fixtures/project", __dir__)) do
        with_clean_bundler_env do
          Bundleup::CLI.new(["--group=development"]).run
        end
      end
    end
    assert_includes(stdout, "running: bundle update --group=development")
  end

  def test_it_displays_usage
    stdout = capturing_plain_output do
      Bundleup::CLI.new(["-h"]).run
    end

    assert_includes(stdout, "Usage: bundleup [GEMS...] [OPTIONS]")
  end

  def test_it_raises_if_gemfile_not_present_in_working_dir
    Dir.chdir(__dir__) do
      error = assert_raises(Bundleup::CLI::Error) { Bundleup::CLI.new([]).run }
      assert_equal("Gemfile and Gemfile.lock must both be present.", error.message)
    end
  end

  def test_update_gemfile_flag # rubocop:disable Minitest/MultipleAssertions
    stdout, updated_gemfile = within_copy_of_sample_project do
      out = capturing_plain_output(stdin: "y\n") do
        with_clean_bundler_env do
          Bundleup::CLI.new(["--update-gemfile"]).run
        end
      end
      [out, IO.read("Gemfile")]
    end

    assert_match(/^mail\s+2\.7\.0\s+→ [\d.]+\s*$/, stdout)
    assert_match(/^mocha\s+1\.11\.1\s+→ [\d.]+\s*$/, stdout)
    assert_match(/^rubocop\s+0\.89\.0\s+→ [\d.]+\s*$/, stdout)
    assert_match(/^rake\s+12\.3\.3\s+→ [\d.]+\s+:\s+pinned at ~> 12\.0\s+# Not ready for 13 yet\s*$/, stdout)
    assert_includes(stdout, "Do you want to apply these changes [Yn]?")
    assert_includes(stdout, "✔ Done!")

    assert_includes(updated_gemfile, <<~GEMFILE)
      gem "mail"
      gem "mocha"
      gem "rake", "~> 12.0" # Not ready for 13 yet
    GEMFILE
    assert_match(/^gem "rubocop", "[.\d]+"$/, updated_gemfile)
    refute_match(/^gem "rubocop", "0.89.0"$/, updated_gemfile)
  end

  private

  def with_clean_bundler_env(&block)
    if defined?(Bundler)
      if Bundler.respond_to?(:with_unbundled_env)
        Bundler.with_unbundled_env(&block)
      else
        Bundler.with_clean_env(&block)
      end
    else
      yield
    end
  end

  def within_copy_of_sample_project(&block)
    sample_dir = File.expand_path("../fixtures/project", __dir__)
    sample_files = %w[Gemfile Gemfile.lock].map { |file| File.join(sample_dir, file) }

    Dir.mktmpdir do |path|
      FileUtils.cp(sample_files, path)
      Dir.chdir(path, &block)
    end
  end
end
