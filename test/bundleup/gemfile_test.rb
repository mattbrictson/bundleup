require "test_helper"

class Bundleup::GemfileTest < Minitest::Test
  def test_gem_comment
    gemfile_path = File.expand_path("../fixtures/Gemfile.sample", __dir__)
    gemfile = Bundleup::Gemfile.new(gemfile_path)

    assert_nil(gemfile.gem_comment("redis"))
    assert_nil(gemfile.gem_comment("spring-watcher-listen"))
    assert_nil(gemfile.gem_comment("whatever"))

    assert_equal(
      "# Call 'byebug' anywhere in the code to stop execution and get a "\
      "debugger console",
      gemfile.gem_comment("byebug")
    )
    assert_equal(
      "# Build JSON APIs with ease. Read more: "\
      "https://github.com/rails/jbuilder",
      gemfile.gem_comment("jbuilder")
    )
    assert_equal(
      "# This is needed for driven_by :chrome",
      gemfile.gem_comment("selenium-webdriver")
    )
  end
end
