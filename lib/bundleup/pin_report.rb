module Bundleup
  class PinReport < Report
    def initialize(gem_versions:, outdated_gems:, gem_comments:)
      super()
      @gem_versions = gem_versions
      @outdated_gems = outdated_gems
      @gem_comments = gem_comments
    end

    def title
      return "Note that this gem is being held back:" if rows.one?

      "Note that the following gems are being held back:"
    end

    def rows
      outdated_gems.keys.sort.map do |gem|
        meta = outdated_gems[gem]
        current_version = gem_versions[gem]
        newest_version = meta[:newest]
        pin = meta[:pin]

        [gem, current_version, "→", newest_version, *pin_reason(gem, pin)]
      end
    end

    def pinned_gems
      outdated_gems.keys.sort
    end

    private

    attr_reader :gem_versions, :outdated_gems, :gem_comments

    def pin_reason(gem, pin)
      notes = Colors.gray(gem_comments[gem].to_s)
      pin_operator, pin_version = pin.split(" ", 2)
      [":", "pinned at", pin_operator.rjust(2), pin_version, notes]
    end
  end
end
