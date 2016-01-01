require "test_helper"

class Bundleup::GemStatusTest < Minitest::Test
  def test_color_with_no_new_version_is_red
    status = Bundleup::GemStatus.new("foo", "1.0.0", nil)
    assert_equal(:red, status.color)
  end

  def test_color_with_no_old_version_is_blue
    status = Bundleup::GemStatus.new("foo", nil, "1.0.0")
    assert_equal(:blue, status.color)
  end

  def test_color_with_sha_version_change_is_red
    status = Bundleup::GemStatus.new("foo", "dc92790", "a032a49")
    assert_equal(:red, status.color)
  end

  def test_color_with_major_version_change_is_red
    status = Bundleup::GemStatus.new("foo", "1.2.0", "2.0.0")
    assert_equal(:red, status.color)
  end

  def test_color_with_minor_version_change_is_yellow
    status = Bundleup::GemStatus.new("foo", "1.2.0", "1.4.1")
    assert_equal(:yellow, status.color)
  end

  def test_color_with_patch_version_change_is_plain
    status = Bundleup::GemStatus.new("foo", "1.2.0", "1.2.11")
    assert_equal(:plain, status.color)
  end

  def test_color_with_no_version_change_is_plain
    status = Bundleup::GemStatus.new("foo", "1.2.0", "1.2.0")
    assert_equal(:plain, status.color)
  end
end
