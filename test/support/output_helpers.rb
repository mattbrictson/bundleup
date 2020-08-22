module OutputHelpers
  private

  def capturing_plain_output(stdin: nil)
    without_color do
      original_logger = Bundleup.logger
      stdout = StringIO.new
      stdin = stdin.nil? ? $stdin : StringIO.new(stdin)
      Bundleup.logger = Bundleup::Logger.new(stdout: stdout, stdin: stdin)
      yield
      stdout.string
    ensure
      Bundleup.logger = original_logger
    end
  end

  def with_color
    original_color = Bundleup::Colors.enabled?
    Bundleup::Colors.enabled = true
    yield
  ensure
    Bundleup::Colors.enabled = original_color
  end

  def without_color
    original_color = Bundleup::Colors.enabled?
    Bundleup::Colors.enabled = false
    yield
  ensure
    Bundleup::Colors.enabled = original_color
  end
end
