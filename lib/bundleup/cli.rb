module Bundleup
  class CLI
    include Console

    def run
      puts \
        "Please wait a moment while I upgrade your Gemfile.lock..."

      committed = false
      review_upgrades
      review_pins
      committed = upgrades.any? && confirm_commit
      puts "Done!" if committed
    ensure
      restore_lockfile unless committed
    end

    private

    def review_upgrades
      if upgrades.any?
        puts "\nThe following gem(s) will be updated:\n\n"
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

    def confirm_commit
      confirm("\nDo you want to apply these changes?")
    end

    def restore_lockfile
      return unless defined?(@upgrade)
      return unless upgrade.lockfile_changed?
      upgrade.undo
      puts "Your original Gemfile.lock has been restored."
    end

    def upgrade
      @upgrade ||= Upgrade.new(ARGV)
    end

    def upgrades
      upgrade.upgrades
    end

    def pins
      upgrade.pins
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
        reason = [":", "pinned at", pin_operator.rjust(2), pin_version]
        [g.name, g.new_version, "→", g.newest_version, *reason]
      end
      puts rows.join("\n")
    end
  end
end
