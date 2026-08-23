require "mocha/api"

Mocha::ExpectationErrorFactory.exception_class = Megatest::Assertion

module Bundleup
  class Test < Megatest::Test
    include Mocha::API

    setup do
      mocha_setup
    end

    teardown do
      @__m.record_failures { mocha_verify }
      mocha_teardown
    end
  end
end
