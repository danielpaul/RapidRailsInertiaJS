# frozen_string_literal: true

# Configure Resend for production email delivery.
# See https://resend.com/docs/send-with-rails
Resend.api_key = Rails.application.credentials.dig(:resend, :api_key) || ENV["RESEND_API_KEY"]
