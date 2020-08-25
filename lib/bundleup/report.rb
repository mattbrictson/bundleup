require "forwardable"

module Bundleup
  class Report
    extend Forwardable
    def_delegators :rows, :empty?

    def to_s
      [
        title,
        indent(tableize(rows).map { |row| row.join(" ").rstrip }.join("\n")),
        ""
      ].join("\n\n")
    end

    private

    def indent(str)
      str.gsub(/^/, "  ")
    end

    def tableize(rows)
      widths = max_length_of_each_column(rows)
      rows.map do |row|
        row.zip(widths).map do |value, width|
          padding = " " * (width - Colors.strip(value).length)
          "#{value}#{padding}"
        end
      end
    end

    def max_length_of_each_column(rows)
      Array.new(rows.first.count) do |i|
        rows.map { |values| Colors.strip(values[i]).length }.max
      end
    end
  end
end
