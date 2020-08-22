module Bundleup
  class Backup
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
