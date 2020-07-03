module Bundleup
  module OutdatedParser
    def self.parse(output)
      expr = if output.match?(/^Gem\s+Current\s+Latest/)
               # Bundler >= 2.2 format
               /^(\S+)\s\s+\S+\s\s+(\d\S+)\s\s+(\S.*?)(?:$|\s\s)/
             else
               # Bundler < 2.2
               /\* (\S+) \(newest (\S+),.* requested (.*)\)/
             end

      output.scan(expr).map do |name, newest, pin|
        { name: name, newest: newest, pin: pin }
      end
    end
  end
end
