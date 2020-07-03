require "test_helper"

class Bundleup::OutdatedParserTest < Minitest::Test
  def test_parse_2_1
    assert_equal(
      [
        { name: "redis", newest: "4.2.1", pin: "~> 4.1.4" },
        { name: "sidekiq", newest: "6.1.0", pin: "~> 6.0" },
        { name: "sprockets", newest: "4.0.2", pin: "~> 3.5" }
      ],
      parse_fixure("outdated-2.1.out")
    )
  end

  def test_parse_2_2
    assert_equal(
      [
        { name: "redis", newest: "4.2.1", pin: "~> 4.1.4" },
        { name: "sidekiq", newest: "6.1.0", pin: "~> 6.0" },
        { name: "sprockets", newest: "4.0.2", pin: "~> 3.5" }
      ],
      parse_fixure("outdated-2.2.out")
    )
  end

  private

  def parse_fixure(fixture)
    fixture_path = File.expand_path("../fixtures/#{fixture}", __dir__)
    Bundleup::OutdatedParser.parse(IO.read(fixture_path))
  end
end
