require "test_helper"

class Bundleup::UpdateReportTest < Minitest::Test
  include OutputHelpers

  def test_singular_title_when_one_gem
    report = Bundleup::UpdateReport.new(
      old_versions: { "rubocop" => "0.89.0" },
      new_versions: { "rubocop" => "0.89.1" }
    )
    assert_equal("This gem will be updated:", report.title)
  end

  def test_plural_title_when_two_gems
    report = Bundleup::UpdateReport.new(
      old_versions: { "rake" => "12.3.3", "rubocop" => "0.89.0" },
      new_versions: { "rake" => "13.0.1", "rubocop" => "0.89.1" }
    )
    assert_equal("The following gems will be updated:", report.title)
  end

  def test_generates_sorted_table
    without_color do
      report = Bundleup::UpdateReport.new(
        old_versions: {
          "i18n" => "1.8.2",
          "zeitwerk" => "2.3.0",
          "json" => "2.2.0",
          "parser" => "2.7.1.1",
          "bundler-audit" => "0.6.1",
          "rails" => "e063bef",
          "thor" => "0.20.3"
        },
        new_versions: {
          "i18n" => "1.8.5",
          "zeitwerk" => "2.4.0",
          "parser" => "2.7.1.4",
          "bundler-audit" => "0.7.0.1",
          "rails" => "57a4ead",
          "rubocop-ast" => "0.3.0",
          "thor" => "1.0.1"
        }
      )
      assert_equal(<<~REPORT, report.to_s)
        The following gems will be updated:

        bundler-audit 0.6.1   → 0.7.0.1
        i18n          1.8.2   → 1.8.5
        json          2.2.0   → (removed)
        parser        2.7.1.1 → 2.7.1.4
        rails         e063bef → 57a4ead
        rubocop-ast   (new)   → 0.3.0
        thor          0.20.3  → 1.0.1
        zeitwerk      2.3.0   → 2.4.0

      REPORT
    end
  end

  def test_colorizes_rows_according_to_semver
    with_color do
      report = Bundleup::UpdateReport.new(
        old_versions: {
          "i18n" => "1.8.2",
          "zeitwerk" => "2.3.0",
          "json" => "2.2.0",
          "parser" => "2.7.1.1",
          "bundler-audit" => "0.6.1",
          "rails" => "e063bef",
          "thor" => "0.20.3"
        },
        new_versions: {
          "i18n" => "1.8.5",
          "zeitwerk" => "2.4.0",
          "parser" => "2.7.1.4",
          "bundler-audit" => "0.7.0.1",
          "rails" => "57a4ead",
          "rubocop-ast" => "0.3.0",
          "thor" => "1.0.1"
        }
      )
      assert_equal(<<~REPORT, report.to_s)
        The following gems will be updated:

        \e[0;33;49mbundler-audit\e[0m \e[0;33;49m0.6.1\e[0m   \e[0;33;49m→\e[0m \e[0;33;49m0.7.0.1\e[0m
        i18n          1.8.2   → 1.8.5
        \e[0;31;49mjson\e[0m          \e[0;31;49m2.2.0\e[0m   \e[0;31;49m→\e[0m \e[0;31;49m(removed)\e[0m
        parser        2.7.1.1 → 2.7.1.4
        \e[0;31;49mrails\e[0m         \e[0;31;49me063bef\e[0m \e[0;31;49m→\e[0m \e[0;31;49m57a4ead\e[0m
        \e[0;34;49mrubocop-ast\e[0m   \e[0;34;49m(new)\e[0m   \e[0;34;49m→\e[0m \e[0;34;49m0.3.0\e[0m
        \e[0;31;49mthor\e[0m          \e[0;31;49m0.20.3\e[0m  \e[0;31;49m→\e[0m \e[0;31;49m1.0.1\e[0m
        \e[0;33;49mzeitwerk\e[0m      \e[0;33;49m2.3.0\e[0m   \e[0;33;49m→\e[0m \e[0;33;49m2.4.0\e[0m

      REPORT
    end
  end
end
