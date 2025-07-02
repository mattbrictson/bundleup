module Bundleup
  class UpdateReport < Report
    def initialize(old_versions:, new_versions:)
      super()
      @old_versions = old_versions
      @new_versions = new_versions
    end

    def title
      return "This gem will be updated:" if rows.one?

      "The following gems will be updated:"
    end

    def rows
      gem_names.each_with_object([]) do |gem, rows|
        old = old_versions[gem]
        new = new_versions[gem]
        next if old == new

        row = [gem, old || "(new)", "→", new || "(removed)"]

        color = color_for_gem(gem)
        rows << row.map { |col| Colors.public_send(color, col) }
      end
    end

    def updated_gems
      gem_names.reject do |gem|
        old_versions[gem] == new_versions[gem]
      end
    end

    private

    attr_reader :old_versions, :new_versions

    def gem_names
      (old_versions.keys | new_versions.keys).sort
    end

    def color_for_gem(gem)
      old_version = old_versions[gem]
      new_version = new_versions[gem]

      return :blue if old_version.nil?
      return :red if new_version.nil? || major_upgrade?(old_version, new_version)
      return :yellow if minor_upgrade?(old_version, new_version)

      :plain
    end

    def major_upgrade?(old_version, new_version)
      major(new_version) != major(old_version)
    end

    def minor_upgrade?(old_version, new_version)
      minor(new_version) != minor(old_version)
    end

    def major(version)
      version.split(".", 2)[0]
    end

    def minor(version)
      version.split(".", 3)[1]
    end
  end
end
