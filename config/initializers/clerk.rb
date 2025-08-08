# frozen_string_literal: true

Clerk.configure do |c|
  c.secret_key = Rails.application.credentials.dig(:clerk, :secret_key) || ENV["CLERK_SECRET_KEY"] || "sk_test_1234567890"
  c.publishable_key = Rails.application.credentials.dig(:clerk, :publishable_key) || ENV["CLERK_PUBLISHABLE_KEY"] || "pk_test_1234567890"
  c.logger = Rails.logger if Rails.env.development?
end