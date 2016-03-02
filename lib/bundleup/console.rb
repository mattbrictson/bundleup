module Bundleup
  module Console
    ANSI_CODES = {
      :red    => 31,
      :green  => 32,
      :yellow => 33,
      :blue   => 34,
      :gray   => 90
    }.freeze

    def ok(message)
      color(:green, "✔ #{message}")
    end

    def attention(message)
      color(:yellow, message)
    end

    def color(color_name, message)
      code = ANSI_CODES[color_name]
      return puts(message) if code.nil?
      puts "\e[0;#{code};49m#{message}\e[0m"
    end

    def confirm(question)
      print question.sub(/\??\z/, " [Yn]? ")
      $stdin.gets =~ /^($|y)/i
    end

    # Runs a block in the background and displays a spinner until it completes.
    def progress(message, &block)
      spinner = %w(/ - \\ |).cycle
      print "\e[90m#{message}... \e[0m"
      result = observing_thread(block, 0.5, 0.1) do
        print "\r\e[90m#{message}... #{spinner.next} \e[0m"
      end
      puts "\r\e[90m#{message}... OK\e[0m"
      result
    rescue StandardError
      puts "\r\e[90m#{message}...\e[0m \e[31mFAILED\e[0m"
      raise
    end

    # Given a two-dimensional Array of strings representing a table of data,
    # translate each row into a single string by joining the values with
    # whitespace such that all the columns are nicely aligned.
    #
    # If a block is given, map the rows through the block first. These two
    # usages are equivalent:
    #
    #   tableize(rows.map(&something))
    #   tableize(rows, &something)
    #
    # Returns a one-dimensional Array of strings, each representing a formatted
    # row of the resulting table.
    #
    def tableize(rows, &block)
      rows = rows.map(&block) if block
      widths = max_length_of_each_column(rows)
      rows.map do |row|
        row.zip(widths).map { |value, width| value.ljust(width) }.join(" ")
      end
    end

    private

    def max_length_of_each_column(rows)
      Array.new(rows.first.count) do |i|
        rows.map { |values| values[i].to_s.length }.max
      end
    end

    # Starts the `callable` in a background thread and waits for it to complete.
    # If the callable fails with an exception, it will be raised here. Otherwise
    # the main thread is paused for an `initial_wait` time in seconds, and
    # subsequently for `periodic_wait` repeatedly until the thread completes.
    # After each wait, `yield` is called to allow a block to execute.
    def observing_thread(callable, initial_wait, periodic_wait)
      thread = Thread.new(&callable)
      wait_for_exit(thread, initial_wait)
      loop do
        break if wait_for_exit(thread, periodic_wait)
        yield
      end
      thread.value
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
