# frozen_string_literal: true

ENV["OPENAI_ACCESS_TOKEN"] = "__OPENAI_ACCESS_TOKEN__"

require "oaib"

require "webmock/rspec"

WebMock.enable!

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.include WebMock::API

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
