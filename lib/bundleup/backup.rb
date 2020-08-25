module Bundleup
  class Backup
    def self.restore_on_error(path)
      backup = new(path)
      begin
        yield(backup)
      rescue StandardError, Interrupt
        backup.restore
        raise
      end
    end

    def initialize(path)
      @path = path
      @original_contents = IO.read(path)
    end

    def restore
      IO.write(path, original_contents)
    end

    private

    attr_reader :path, :original_contents
  end
end
