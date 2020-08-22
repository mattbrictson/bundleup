require "test_helper"

class Bundleup::CLITest < Minitest::Test
  include OutputHelpers

  def test_it_works_with_a_sample_project # rubocop:disable Minitest/MultipleAssertions
    stdout = capturing_plain_output(stdin: "n\n") do
      Dir.chdir(File.expand_path("../fixtures/project", __dir__)) do
        with_clean_bundler_env do
          Bundleup::CLI.new([]).run
        end
      end
    end
    assert_includes(stdout, "Please wait a moment while I upgrade your Gemfile.lock...")
    assert_includes(stdout, "The following gems will be updated:")
    assert_match(/^  mail\s+2\.7\.0\s+→ [\d.]+\s*$/, stdout)
    assert_match(/^  minitest\s+5\.14\.0\s+→ [\d.]+\s*$/, stdout)
    assert_includes(stdout, "Note that the following gems are being held back:")
    assert_match(/^  rake\s+12\.3\.3\s+→ [\d.]+\s+:\s+pinned at ~> 12\.0\s+# Not ready for 13 yet\s*$/, stdout)
    assert_match(/^  rubocop\s+0\.89\.0\s+→ [\d.]+\s+:\s+pinned at  = 0\.89\.0\s*$/, stdout)
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
end
