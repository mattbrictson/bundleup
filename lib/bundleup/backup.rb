module Bundleup
  class Backup
    def self.restore_on_error(*paths)
      backup = new(*paths)
      begin
        yield(backup)
      rescue StandardError, Interrupt
        backup.restore
        raise
      end
    end

    def initialize(*paths)
      @original_contents = paths.to_h do |path|
        [path, File.read(path)]
      end
    end

    def restore
      original_contents.each do |path, contents|
        File.write(path, contents)
      end
    end

    private

    attr_reader :original_contents
  end
end
