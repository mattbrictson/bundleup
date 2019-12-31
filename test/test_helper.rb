$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bundleup"

# Load everything else from test/support
Dir[File.expand_path("support/**/*.rb", __dir__)].each { |rb| require(rb) }

require "minitest/autorun"
