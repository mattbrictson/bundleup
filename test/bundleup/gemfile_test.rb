require "test_helper"

class Bundleup::GemfileTest < Minitest::Test
  def test_gem_comments
    gemfile_path = File.expand_path("../fixtures/Gemfile.sample", __dir__)
    gemfile = Bundleup::Gemfile.new(gemfile_path)

    # rubocop:disable Layout/LineLength
    assert_equal(
      {
        "rails" => "# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'",
        "pg" => "# Use postgresql as the database for Active Record",
        "puma" => "# Use Puma as the app server",
        "sass-rails" => "# Use SCSS for stylesheets",
        "uglifier" => "# Use Uglifier as compressor for JavaScript assets",
        "coffee-rails" => "# Use CoffeeScript for .coffee assets and views",
        "turbolinks" => "# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks",
        "jbuilder" => "# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder",
        "byebug" => "# Call 'byebug' anywhere in the code to stop execution and get a debugger console",
        "capybara" => "# Adds support for Capybara system testing and selenium driver",
        "selenium-webdriver" => "# This is needed for driven_by :chrome",
        "web-console" => "# Access an IRB console on exception pages or by using <%= console %> anywhere in the code.",
        "spring" => "# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring",
        "tzinfo-data" => "# Windows does not include zoneinfo files, so bundle the tzinfo-data gem"
      },
      gemfile.gem_comments
    )
    # rubocop:enable Layout/LineLength
  end
end
