require "test_helper"

class BundleupTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Bundleup::VERSION
  end
end
