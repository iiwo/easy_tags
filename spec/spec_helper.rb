require 'bundler/setup'
require 'rspec'
require 'easy_tags'
require 'database_cleaner'
require 'simplecov'
require 'simplecov-console'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.start

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.raise_errors_for_deprecations!

  config.before(:suite) do
    Database.prepare
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
