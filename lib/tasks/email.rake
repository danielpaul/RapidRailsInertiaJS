# frozen_string_literal: true

namespace :email do
  desc "Test email delivery configuration"
  task test: :environment do
    puts "Testing email configuration..."
    puts "Environment: #{Rails.env}"
    puts "Delivery method: #{Rails.application.config.action_mailer.delivery_method}"
    puts "Default from address: #{ApplicationMailer.default[:from]}"

    if Rails.env.production?
      api_key = Rails.application.credentials.dig(:resend, :api_key) || ENV["RESEND_API_KEY"]
      if api_key.present?
        puts "✅ Resend API key is configured"
        puts "API key: #{api_key[0..6]}..." # Show only first 7 characters for security
      else
        puts "❌ Resend API key is missing from credentials"
        puts "Run: EDITOR='your_editor' rails credentials:edit"
        puts "Add: resend:\n       api_key: your_api_key_here"
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
