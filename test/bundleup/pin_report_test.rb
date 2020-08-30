require "test_helper"

class Bundleup::PinReportTest < Minitest::Test
  include OutputHelpers

  def test_singular_title_when_one_gem
    report = Bundleup::PinReport.new(
      gem_versions: { "rubocop" => "0.89.0" },
      outdated_gems: { "rubocop" => { newest: "0.89.1", pin: "= 0.89.0" } },
      gem_comments: {}
    )
    assert_equal("Note that this gem is being held back:", report.title)
  end

  def test_plural_title_when_two_gems
    report = Bundleup::PinReport.new(
      gem_versions: { "rake" => "12.3.3", "rubocop" => "0.89.0" },
      outdated_gems: {
        "rake" => { newest: "13.0.1", pin: "~> 12.0" },
        "rubocop" => { newest: "0.89.1", pin: "= 0.89.0" }
      },
      gem_comments: {}
    )
    assert_equal("Note that the following gems are being held back:", report.title)
  end

  def test_generates_sorted_table_with_pins_and_gray_color_comments
    with_color do
      report = Bundleup::PinReport.new(
        gem_versions: { "rake" => "12.3.3", "rubocop" => "0.89.0" },
        outdated_gems: {
          "rubocop" => { newest: "0.89.1", pin: "= 0.89.0" },
          "rake" => { newest: "13.0.1", pin: "~> 12.0" }
        },
        gem_comments: { "rake" => "# Not ready for 13 yet" }
      )
      assert_equal(<<~REPORT, report.to_s)
        Note that the following gems are being held back:

        rake    12.3.3 → 13.0.1 : pinned at ~> 12.0   \e[0;90;49m# Not ready for 13 yet\e[0m
        rubocop 0.89.0 → 0.89.1 : pinned at  = 0.89.0

      REPORT
    end
  end
end
