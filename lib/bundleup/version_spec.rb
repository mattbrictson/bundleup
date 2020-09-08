module Bundleup
  class VersionSpec
    def self.parse(version)
      return version if version.is_a?(VersionSpec)

      version = version.strip
      _, operator, number = version.match(/^([^\d\s]*)\s*(.+)/).to_a
      operator = nil if operator.empty?

      new(parts: number.split("."), operator: operator)
    end

    attr_reader :parts, :operator

    def initialize(parts:, operator: nil)
      @parts = parts
      @operator = operator
    end

    def exact?
      operator.nil?
    end

    def relax
      return self if %w[!= > >=].include?(operator)

      self.class.new(parts: parts, operator: ">=")
    end

    def shift(new_version)
      return self if %w[!= >].include?(operator)

      new_version = self.class.parse(new_version)
      new_slice = exact? ? new_version : new_version.slice(parts.length)
      self.class.new(parts: new_slice.parts, operator: operator)
    end

    def slice(amount)
      self.class.new(parts: parts[0, amount], operator: operator)
    end

    def to_s
      [operator, parts.join(".")].compact.join(" ")
    end
  end
end
