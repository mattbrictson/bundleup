# rubocop:disable Metrics/BlockLength
module Bundleup
  GemStatus = Struct.new(:name,
                         :old_version,
                         :new_version,
                         :newest_version,
                         :pin) do
    def pinned?
      !pin.nil?
    end

    def upgraded?
      new_version != old_version
    end

    def added?
      old_version.nil?
    end

    def removed?
      new_version.nil?
    end

    def color
      if major_upgrade? || removed?
        :red
      elsif minor_upgrade?
        :yellow
      elsif added?
        :blue
      else
        :plain
      end
    end

    def major_upgrade?
      return false if new_version.nil? || old_version.nil?
      major(new_version) != major(old_version)
    end

    def minor_upgrade?
      return false if new_version.nil? || old_version.nil?
      !major_upgrade? && minor(new_version) != minor(old_version)
    end

    private

    def major(version)
      version.split(".", 2)[0]
    end

    def minor(version)
      version.split(".", 3)[1]
    end
  end
end
