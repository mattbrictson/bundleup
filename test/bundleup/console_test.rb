require "test_helper"

class Bundleup::ConsoleTest < Minitest::Test
  def test_color
    console = Object.new.extend(Bundleup::Console)

    assert_equal("\e[0;31;49mwonderful\e[0m", console.color(:red, "wonderful"))
    assert_equal("\e[0;33;49mnice\e[0m", console.color(:yellow, "nice"))
    assert_equal("hello", console.color(nil, "hello"))
    assert_equal("goodbye", console.color(:wut, "goodbye"))
  end
end
