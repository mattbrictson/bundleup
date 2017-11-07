module Bundleup
  class Gemfile
    def initialize(path="Gemfile")
      @contents = IO.read(path)
    end

    def gem_comment(gem_name)
      inline_comment(gem_name) || prefix_comment(gem_name)
    end

    private

    attr_reader :contents

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
