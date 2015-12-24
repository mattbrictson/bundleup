module Bundleup
  class CLI
    include Console

    def run
      puts \
        "Please wait a moment while I try upgrading a copy of your Gemfile..."

      review_upgrades
      review_pins
      offer_bundle_update if upgrades.any?
    end

    private

    def review_upgrades
      if upgrades.any?
        puts "\nIt looks like the following gem(s) will be updated:\n\n"
        print_upgrades_table
      else
        ok("Nothing to update.")
      end
    end

    def review_pins
      return if pins.empty?
      puts "\nNote that the following gem(s) are being held back:\n\n"
      print_pins_table
    end

    def offer_bundle_update
      exec "bundle update" if confirm("\nShall I run `bundle update` for you?")
    end

    def gemfile
      @gemfile ||= Gemfile.new
    end

    def upgrades
      gemfile.upgrades
    end

    def pins
      gemfile.pins
    end

    def print_upgrades_table
      rows = tableize(upgrades) do |g|
        [g.name, g.old_version || "(new)", "→", g.new_version || "(removed)"]
      end
      upgrades.zip(rows).each do |g, row|
        color(g.color, row)
      end
    end

    def print_pins_table
      rows = tableize(pins) do |g|
        pin_operator, pin_version = g.pin.split(" ", 2)
        reason = [":", "pinned at", pin_operator, pin_version]
        [g.name, g.new_version, "→", g.newest_version, *reason]
      end
      puts rows.join("\n")
    end
  end
end
