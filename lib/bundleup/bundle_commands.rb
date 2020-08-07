require "open3"

module Bundleup
  class BundleCommands
    class Result
      attr_reader :output

      def initialize(output, success)
        @output = output
        @success = success
      end

      def success?
        @success
      end
    end

    include Console

    def check
      run(%w[bundle check], true).success?
    end

    def install
      run(%w[bundle install]).output
    end

    def outdated
      run(%w[bundle outdated], true).output
    end

    def list
      run(%w[bundle list]).output
    end

    def update(args=[])
      run(%w[bundle update] + args).output
    end

    private

    def run(cmd, fail_silently=false)
      cmd_line = cmd.join(" ")
      progress("Running `#{cmd_line}`") do
        out, err, status = Open3.capture3(*cmd)
        next(Result.new(out, status.success?)) if status.success? || fail_silently

        raise ["Failed to execute: #{cmd_line}", out, err].compact.join("\n")
      end
    end
  end
end
