require "forwardable"
require "open3"

module Bundleup
  class Shell
    extend Forwardable
    def_delegators :Bundleup, :logger

    def capture(command, raise_on_error: true)
      stdout, stderr, status = capture3(command)
      raise ["Failed to execute: #{command}", stdout, stderr].compact.join("\n") if raise_on_error && !status.success?

      stdout
    end

    def run(command)
      capture(command)
      true
    end

    def run?(command)
      _, _, status = capture3(command)
      status.success?
    end

    private

    def capture3(command)
      command = Array(command)
      logger.while_spinning("running: #{command.join(' ')}") do
        Open3.capture3(*command)
      end
    end
  end
end
