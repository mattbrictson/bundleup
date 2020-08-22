require "test_helper"
require "tempfile"

class Bundleup::BackupTest < Minitest::Test
  def test_restore
    original_contents = "Hello, world!\n"
    file = Tempfile.new
    file << original_contents
    file.close

    backup = Bundleup::Backup.new(file.path)

    assert_equal(original_contents, IO.read(file.path))

    IO.write(file.path, "Modified!\n")
    assert_equal("Modified!\n", IO.read(file.path))

    backup.restore
    assert_equal(original_contents, IO.read(file.path))
  end
end
