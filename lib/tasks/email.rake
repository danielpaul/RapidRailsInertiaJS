# frozen_string_literal: true

namespace :email do
  desc "Test email delivery configuration"
  task test: :environment do
    puts "Testing email configuration..."
    puts "Environment: #{Rails.env}"
    puts "Delivery method: #{Rails.application.config.action_mailer.delivery_method}"
    puts "Default from address: #{ApplicationMailer.default[:from]}"

    if Rails.env.production?
      api_token = Rails.application.credentials.dig(:postmark, :api_token)
      if api_token.present?
        puts "✅ Postmark API token is configured"
        puts "API token: #{api_token[0..6]}..." # Show only first 7 characters for security
      else
        puts "❌ Postmark API token is missing from credentials"
        puts "Run: EDITOR='your_editor' rails credentials:edit"
        puts "Add: postmark:\n       api_token: your_token_here"
      end
    end

    puts "✅ Email configuration test complete"
  end

  desc "Send a test email (requires USER_EMAIL environment variable)"
  task send_test: :environment do
    email = ENV["USER_EMAIL"]

    if email.blank?
      puts "❌ Please provide USER_EMAIL environment variable"
      puts "Usage: USER_EMAIL=test@example.com rails email:send_test"
      exit 1
    end

    # Create a minimal user-like object for testing
    test_user = OpenStruct.new(
      email: email,
      generate_token_for: ->(purpose) { SecureRandom.hex(20) }
    )

    puts "❌ No mailer methods available for testing"
    puts "Add mailer methods to UserMailer to test email delivery"
  end
end
