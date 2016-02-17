require "open3"

module Bundleup
  class BundleCommands
    include Console

    def outdated
      run("bundle outdated", true)
    end

    def show
      run("bundle show")
    end

    def update
      run("bundle update")
    end

    private

    def run(cmd, fail_silently=false)
      progress("Running `#{cmd}`") do
        out, err, status = Open3.capture3(cmd)
        next(out) if status.success? || fail_silently

        raise ["Failed to execute: #{cmd}", out, err].compact.join("\n")
      end
    end
  end
end
