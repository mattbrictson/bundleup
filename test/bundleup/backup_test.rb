require "test_helper"
require "tempfile"

class Bundleup::BackupTest < Minitest::Test
  def test_restore_on_error
    original_contents = ["Hello, world!\n", "Another file\n"]
    files = original_contents.map do |content|
      file = Tempfile.new
      file << content
      file.close
      file
    end

    assert_raises(StandardError, "oh no!") do
      Bundleup::Backup.restore_on_error(*files.map(&:path)) do
        files.each { |file| File.write(file.path, "Modified!\n") }
        raise "oh no!"
      end
    end

    original_contents.zip(files).each do |content, file|
      assert_equal(content, File.read(file.path))
    end
  end

  def test_restore
    original_contents = "Hello, world!\n"
    file = Tempfile.new
    file << original_contents
    file.close

    backup = Bundleup::Backup.new(file.path)

    assert_equal(original_contents, File.read(file.path))

    File.write(file.path, "Modified!\n")
    assert_equal("Modified!\n", File.read(file.path))

    backup.restore
    assert_equal(original_contents, File.read(file.path))
  end
end
