# frozen_string_literal: true

# Application constants that can be configured per environment
# These values can be overridden via environment variables in production
module AppConstants
  # App Identity
  APP_NAME = ENV.fetch('APP_NAME', 'RapidRails').freeze
  APP_URL = ENV.fetch('APP_URL', 'http://localhost:3000').freeze
  
  # Company Information
  COMPANY_NAME = ENV.fetch('COMPANY_NAME', 'RapidRails Inc.').freeze
  COMPANY_ADDRESS = ENV.fetch('COMPANY_ADDRESS', '123 Main Street, City, State 12345, Country').freeze
  
  # Email Configuration
  FROM_EMAIL = ENV.fetch('FROM_EMAIL', 'noreply@example.com').freeze
  SUPPORT_EMAIL = ENV.fetch('SUPPORT_EMAIL', 'support@example.com').freeze
  
  # Logo URLs (for email templates)
  LOGO_LIGHT_URL = ENV.fetch('LOGO_LIGHT_URL', nil).freeze
  LOGO_DARK_URL = ENV.fetch('LOGO_DARK_URL', nil).freeze
end