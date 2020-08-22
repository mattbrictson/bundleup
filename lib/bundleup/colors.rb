module Bundleup
  module Colors
    ANSI_CODES = {
      red: 31,
      green: 32,
      yellow: 33,
      blue: 34,
      gray: 90
    }.freeze
    private_constant :ANSI_CODES

    class << self
      attr_writer :enabled

      def enabled?
        return @enabled if defined?(@enabled)

        @enabled = determine_color_support
      end

      private

      def determine_color_support
        if ENV["CLICOLOR_FORCE"] == "1"
          true
        elsif ENV["TERM"] == "dumb"
          false
        else
          tty?($stdout) && tty?($stderr)
        end
      end

      def tty?(io)
        io.respond_to?(:tty?) && io.tty?
      end
    end

    module_function

    def plain(str)
      str
    end

    def strip(str)
      str.gsub(/\033\[[0-9;]*m/, "")
    end

    ANSI_CODES.each do |name, code|
      define_method(name) do |str|
        return str if str.to_s.empty?

        Colors.enabled? ? "\e[0;#{code};49m#{str}\e[0m" : str
      end
    end
  end
end
