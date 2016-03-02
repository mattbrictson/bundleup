require "open3"

module Bundleup
  class BundleCommands
    include Console

    def outdated
      run(%w(bundle outdated), true)
    end

    def show
      run(%w(bundle show))
    end

    def update(args=[])
      run(%w(bundle update) + args)
    end

    private

    def run(cmd, fail_silently=false)
      cmd_line = cmd.join(" ")
      progress("Running `#{cmd_line}`") do
        out, err, status = Open3.capture3(*cmd)
        next(out) if status.success? || fail_silently
        raise ["Failed to execute: #{cmd_line}", out, err].compact.join("\n")
      end
    end
  end
end
