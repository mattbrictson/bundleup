require "test_helper"

class Bundleup::LoggerTest < Minitest::Test
  include OutputHelpers

  def test_confirm_with_default_response
    stdout = capturing_plain_output(stdin: "\n") do
      confirmed = Bundleup.logger.confirm?("Are you sure?")
      assert(confirmed)
    end

    assert_equal("Are you sure [Yn]? ", stdout)
  end

  def test_confirm_with_y_response
    capturing_plain_output(stdin: "y\n") do
      confirmed = Bundleup.logger.confirm?("Are you sure?")
      assert(confirmed)
    end
  end

  def test_confirm_with_n_response
    capturing_plain_output(stdin: "n\n") do
      confirmed = Bundleup.logger.confirm?("Are you sure?")
      refute(confirmed)
    end
  end
end
