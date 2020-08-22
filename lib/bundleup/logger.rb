require "io/console"

module Bundleup
  class Logger
    extend Forwardable
    def_delegators :@stdout, :print, :puts, :tty?
    def_delegators :@stdin, :gets

    def initialize(stdin: $stdin, stdout: $stdout, stderr: $stderr)
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
      @spinner = %w[⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏].cycle
    end

    def ok(message)
      puts Colors.green("✔ #{message}")
    end

    def error(message)
      stderr.puts Colors.red("ERROR: #{message}")
    end

    def attention(message)
      puts Colors.yellow(message)
    end

    def confirm?(question)
      print Colors.yellow(question.sub(/\??\z/, " [Yn]? "))
      gets =~ /^($|y)/i
    end

    def clear_line
      print "\r".ljust(console_width - 1)
      print "\r"
    end

    def while_spinning(message, &block)
      thread = Thread.new(&block)
      message = message.ljust(console_width - 2)
      print "\r#{Colors.blue([spinner.next, message].join(' '))}" until wait_for_exit(thread, 0.1)
      thread.value
    end

    private

    attr_reader :spinner, :stderr

    def console_width
      width = IO.console.winsize.last if tty?
      width.to_i.positive? ? width : 80
    end

    def wait_for_exit(thread, seconds)
      thread.join(seconds)
    rescue StandardError
      # Sanity check. If we get an exception, the thread should be dead.
      raise if thread.alive?

      thread
    end
  end
end
