require "test_helper"
require "tempfile"

class Bundleup::GemfileTest < Minitest::Test
  def test_gem_comments
    gemfile = with_copy_of_sample_gemfile { |path| Bundleup::Gemfile.new(path) }

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

  def test_gem_pins_without_comments
    gemfile = with_copy_of_sample_gemfile { |path| Bundleup::Gemfile.new(path) }
    assert_equal(
      {
        "spring-watcher-listen" => Bundleup::VersionSpec.parse("~> 2.0.0")
      },
      gemfile.gem_pins_without_comments
    )
  end

  def test_relax_gem_pins!
    with_copy_of_sample_gemfile do |path|
      Bundleup::Gemfile.new(path).relax_gem_pins!(%w[rails uglifier capybara])

      assert_equal(<<~'GEMFILE', IO.read(path))
        source 'https://rubygems.org'

        git_source(:github) do |repo_name|
          repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
          "https://github.com/#{repo_name}.git"
        end


        # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
        gem 'rails', '>= 5.1.4'
        # Use postgresql as the database for Active Record
        gem 'pg', '~> 0.18'
        # Use Puma as the app server
        gem 'puma', '~> 3.7'
        # Use SCSS for stylesheets
        gem 'sass-rails', '~> 5.0'
        # Use Uglifier as compressor for JavaScript assets
        gem 'uglifier', '>= 1.3.0'
        # See https://github.com/rails/execjs#readme for more supported runtimes
        # gem 'therubyracer', platforms: :ruby

        # Use CoffeeScript for .coffee assets and views
        gem 'coffee-rails', '~> 4.2'
        # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
        gem 'turbolinks', '~> 5'
        # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
        gem 'jbuilder', '~> 2.5'
        # Use Redis adapter to run Action Cable in production
        # gem 'redis', '~> 3.0'
        # Use ActiveModel has_secure_password
        # gem 'bcrypt', '~> 3.1.7'

        # Use Capistrano for deployment
        # gem 'capistrano-rails', group: :development

        group :development, :test do
          # Call 'byebug' anywhere in the code to stop execution and get a debugger console
          gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
          # Adds support for Capybara system testing and selenium driver
          gem 'capybara', '>= 2.13'
          gem 'selenium-webdriver' # This is needed for driven_by :chrome
        end

        group :development do
          # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
          gem 'web-console', '>= 3.3.0'
          gem 'listen', '>= 3.0.5', '< 3.2'
          # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
          gem 'spring'
          gem 'spring-watcher-listen', '~> 2.0.0'
        end

        # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
        gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
      GEMFILE
    end
  end

  def test_shift_gem_pins!
    with_copy_of_sample_gemfile do |path|
      Bundleup::Gemfile.new(path).shift_gem_pins!(
        "rails" => "6.0.1.3",
        "uglifier" => "1.4.5",
        "capybara" => "3.9.1"
      )

      assert_equal(<<~'GEMFILE', IO.read(path))
        source 'https://rubygems.org'

        git_source(:github) do |repo_name|
          repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
          "https://github.com/#{repo_name}.git"
        end


        # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
        gem 'rails', '~> 6.0.1'
        # Use postgresql as the database for Active Record
        gem 'pg', '~> 0.18'
        # Use Puma as the app server
        gem 'puma', '~> 3.7'
        # Use SCSS for stylesheets
        gem 'sass-rails', '~> 5.0'
        # Use Uglifier as compressor for JavaScript assets
        gem 'uglifier', '>= 1.3.0'
        # See https://github.com/rails/execjs#readme for more supported runtimes
        # gem 'therubyracer', platforms: :ruby

        # Use CoffeeScript for .coffee assets and views
        gem 'coffee-rails', '~> 4.2'
        # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
        gem 'turbolinks', '~> 5'
        # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
        gem 'jbuilder', '~> 2.5'
        # Use Redis adapter to run Action Cable in production
        # gem 'redis', '~> 3.0'
        # Use ActiveModel has_secure_password
        # gem 'bcrypt', '~> 3.1.7'

        # Use Capistrano for deployment
        # gem 'capistrano-rails', group: :development

        group :development, :test do
          # Call 'byebug' anywhere in the code to stop execution and get a debugger console
          gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
          # Adds support for Capybara system testing and selenium driver
          gem 'capybara', '~> 3.9'
          gem 'selenium-webdriver' # This is needed for driven_by :chrome
        end

        group :development do
          # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
          gem 'web-console', '>= 3.3.0'
          gem 'listen', '>= 3.0.5', '< 3.2'
          # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
          gem 'spring'
          gem 'spring-watcher-listen', '~> 2.0.0'
        end

        # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
        gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
      GEMFILE
    end
  end

  private

  def with_copy_of_sample_gemfile
    file = Tempfile.new
    file << IO.read(File.expand_path("../fixtures/Gemfile.sample", __dir__))
    file.close
    yield file.path
  end
end
