# Coveralls has to be loaded first
require_relative("./support/coveralls")

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "bundleup"

# Load everything else from test/support
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |rb| require(rb) }

require "minitest/autorun"
