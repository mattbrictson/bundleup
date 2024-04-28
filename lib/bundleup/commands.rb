require "forwardable"

module Bundleup
  class Commands
    GEMFILE_ENTRY_REGEXP = /\* (\S+) \((\S+)(?: (\S+))?\)/
    OUTDATED_2_1_REGEXP = /\* (\S+) \(newest (\S+),.* requested (.*)\)/
    OUTDATED_2_2_REGEXP = /^(\S+)\s\s+\S+\s\s+(\d\S+)\s\s+(\S.*?)(?:$|\s\s)/

    extend Forwardable
    def_delegators :Bundleup, :shell

    def check?
      shell.run?(%w[bundle check])
    end

    def install
      shell.run(%w[bundle install])
    end

    def list
      output = shell.capture(%w[bundle list])
      output.scan(GEMFILE_ENTRY_REGEXP).each_with_object({}) do |(name, ver, sha), gems|
        gems[name] = sha || ver
      end
    end

    def outdated
      output = shell.capture(%w[bundle outdated], raise_on_error: false)
      expr = output.match?(/^Gem\s+Current\s+Latest/) ? OUTDATED_2_2_REGEXP : OUTDATED_2_1_REGEXP

      output.scan(expr).each_with_object({}) do |(name, newest, pin), gems|
        gems[name] = { newest:, pin: }
      end
    end

    def update(args=[])
      shell.run(%w[bundle update] + args)
    end
  end
end
