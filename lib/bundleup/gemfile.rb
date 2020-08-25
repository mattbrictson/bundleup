module Bundleup
  class Gemfile
    def initialize(path="Gemfile")
      @contents = IO.read(path)
    end

    def gem_comments
      gem_names.each_with_object({}) do |gem, hash|
        comment = inline_comment(gem) || prefix_comment(gem)
        hash[gem] = comment unless comment.nil?
      end
    end

    private

    attr_reader :contents

    def gem_names
      contents.scan(/^\s*gem\s+["'](.+?)["']/).flatten.uniq
    end

    def inline_comment(gem_name)
      contents[/#{gem_declaration_re(gem_name)}.*(#\s*\S+.*)/, 1]
    end

    def prefix_comment(gem_name)
      contents[/^\s*(#\s*\S+.*)\n#{gem_declaration_re(gem_name)}/, 1]
    end

    def gem_declaration_re(gem_name)
      /^\s*gem\s+["']#{Regexp.escape(gem_name)}["']/
    end
  end
end
