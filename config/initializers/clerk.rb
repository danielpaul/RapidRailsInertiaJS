# frozen_string_literal: true

require 'clerk'

# Configure Clerk SDK
Clerk.configure do |config|
  config.api_key = Rails.application.credentials.dig(:clerk, :api_key) || ENV['CLERK_API_KEY']
  config.base_url = Rails.application.credentials.dig(:clerk, :base_url) || ENV['CLERK_API_BASE']
end