# frozen_string_literal: true

require 'capybara'
require 'capybara/rspec'
require 'webdrivers/chromedriver'
require 'webmock/rspec'
require 'active_support/testing/time_helpers'

WebMock.disable_net_connect!(allow: [
                               'localhost',
                               '0.0.0.0',
                               '127.0.0.1',
                               'chromedriver.storage.googleapis.com',
                               'storage.googleapis.com',
                               'googlechromelabs.github.io',
                               'storage.googleapis.com',
                               'edgedl.me.gvt1.com'
                             ])
# special setup to make feature tests run on ubuntu 20.4 LTS
if ENV['UBUNTU']
  puts 'Running Rspecs on Ubuntu'
  # Webdrivers.logger.level = :debug
  # On Ubuntu >= 20 Chrome is installed via snap, so provide the path here
  Selenium::WebDriver::Chrome.path = '/snap/chromium/current/usr/lib/chromium-browser/chrome'
  # Webdrivers::Chromedriver.required_version = '114.0.5735.90'
else
  puts 'Running Rspecs on Linux (If you use Ubuntu and encounter problems you might try to call this with "UBUNTU=true")'
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')
  options.add_argument('--disable-features=VizDisplayCompositor')
  options.add_argument('--enable-logging') # Enables logging
  options.add_argument('--log-level=0') # Enables all logging
  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 options: options
end

Capybara.configure do |config|
  config.default_max_wait_time = 5 # seconds
  config.default_driver        = :headless_chrome
end

RSpec.configure do |config|
  config.color = true
  config.warnings = false
  config.include ActiveSupport::Testing::TimeHelpers

  config.include Capybara::DSL
  Capybara.server = :puma, { Silent: true }
  Capybara.javascript_driver = :headless_chrome
  Capybara.server_host = '0.0.0.0' # universal IP
  # Capybara.asset_host = '0.0.0.0:3000' # will not work in github actions

  config.before(:each) do
    stub_request(:get, /server.arcgisonline.com/)
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: 'stubbed response', headers: {})
    stub_request(:get, /api.mapbox.com/)
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: 'stubbed response', headers: {})
    stub_request(:get, /nominatim.openstreetmap.org/)
      .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: 'stubbed response', headers: {})
  end

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.
  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  # config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = 'spec/examples.txt'

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  # config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  # Kernel.srand config.seed
end
