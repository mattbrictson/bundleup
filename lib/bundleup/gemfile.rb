module Bundleup
  class Gemfile
    attr_reader :path

    def initialize(path="Gemfile")
      @path = path
      @contents = IO.read(path)
    end

    def gem_comments
      gem_names.each_with_object({}) do |gem_name, hash|
        comment = inline_comment(gem_name) || prefix_comment(gem_name)
        hash[gem_name] = comment unless comment.nil?
      end
    end

    def gem_pins_without_comments
      (gem_names - gem_comments.keys).each_with_object({}) do |gem_name, hash|
        next unless (match = gem_declaration_with_pinned_version_re(gem_name).match(contents))

        version = match[1]
        hash[gem_name] = VersionSpec.parse(version)
      end
    end

    def relax_gem_pins!(gem_names)
      gem_names.each do |gem_name|
        rewrite_gem_version!(gem_name, &:relax)
      end
    end

    def shift_gem_pins!(new_gem_versions)
      new_gem_versions.each do |gem_name, new_version|
        rewrite_gem_version!(gem_name) { |version_spec| version_spec.shift(new_version) }
      end
    end

    private

    def rewrite_gem_version!(gem_name)
      found = contents.sub!(gem_declaration_with_pinned_version_re(gem_name)) do |match|
        version = Regexp.last_match[1]
        match[Regexp.last_match.regexp, 1] = yield(VersionSpec.parse(version)).to_s
        match
      end
      raise "Can't rewrite version for #{gem_name}; it does not have a pin" unless found

      IO.write(path, contents)
    end

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

    def gem_declaration_with_pinned_version_re(gem_name)
      /#{gem_declaration_re(gem_name)},\s*["'](.*?)["']/
    end
  end
end
