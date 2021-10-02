require "test_helper"

class Bundleup::CommandsTest < Minitest::Test
  def test_check?
    Bundleup.shell.expects(:run?).with(%w[bundle check]).returns(true)
    assert(Bundleup::Commands.new.check?)
  end

  def test_install
    Bundleup.shell.expects(:run).with(%w[bundle install]).returns(true)
    assert(Bundleup::Commands.new.install)
  end

  def test_list
    Bundleup.shell.expects(:capture).with(%w[bundle list]).returns(read_fixture("list.out"))
    gems = Bundleup::Commands.new.list
    assert_equal(118, gems.count)
    assert_equal("f5733d0", gems["friendly_id"])
    assert_equal("2.7.1", gems["rubocop-rails"])
    assert_equal("0.3.6", gems["thread_safe"])
  end

  def test_outdated_2_1
    Bundleup.shell
            .stubs(:capture)
            .with(%w[bundle outdated], raise_on_error: false)
            .returns(read_fixture("outdated-2.1.out"))

    assert_equal(
      {
        "redis" => { newest: "4.2.1", pin: "~> 4.1.4" },
        "sidekiq" => { newest: "6.1.0", pin: "~> 6.0" },
        "sprockets" => { newest: "4.0.2", pin: "~> 3.5" }
      },
      Bundleup::Commands.new.outdated
    )
  end

  def test_outdated_2_2
    Bundleup.shell
            .stubs(:capture)
            .with(%w[bundle outdated], raise_on_error: false)
            .returns(read_fixture("outdated-2.2.out"))

    assert_equal(
      {
        "redis" => { newest: "4.2.1", pin: "~> 4.1.4" },
        "sidekiq" => { newest: "6.1.0", pin: "~> 6.0" },
        "sprockets" => { newest: "4.0.2", pin: "~> 3.5" }
      },
      Bundleup::Commands.new.outdated
    )
  end

  def test_update
    Bundleup.shell.expects(:run).with(%w[bundle update]).returns(true)
    assert(Bundleup::Commands.new.update)
  end

  def test_update_with_args
    Bundleup.shell.expects(:run).with(%w[bundle update --group=development --strict]).returns(true)
    assert(Bundleup::Commands.new.update(%w[--group=development --strict]))
  end

  private

  def read_fixture(fixture)
    fixture_path = File.expand_path("../fixtures/#{fixture}", __dir__)
    File.read(fixture_path)
  end
end
