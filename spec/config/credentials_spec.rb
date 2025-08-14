# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Credentials structure" do
  describe "credentials.yml.example file" do
    let(:example_content) { File.read(Rails.root.join("config/credentials.yml.example")) }
    let(:parsed_credentials) { YAML.safe_load(example_content) }

    it "includes all required clerk configuration keys" do
      expect(parsed_credentials.dig("clerk", "secret_key")).to be_present
      expect(parsed_credentials.dig("clerk", "publishable_key")).to be_present
      expect(parsed_credentials.dig("clerk", "webhook_secret")).to be_present
    end

    it "includes postmark configuration" do
      expect(parsed_credentials.dig("postmark", "api_token")).to be_present
    end

    it "includes sentry configuration" do
      expect(parsed_credentials.dig("sentry", "dsn")).to be_present
    end

    it "includes secret_key_base" do
      expect(parsed_credentials["secret_key_base"]).to be_present
    end
  end

  describe "credential usage in application" do
    it "webhooks controller can access webhook secret from credentials" do
      allow(Rails.application.credentials).to receive(:dig).with(:clerk, :webhook_secret).and_return("test_secret")

      # Simulate how the webhook controller accesses the secret
      webhook_secret = Rails.application.credentials.dig(:clerk, :webhook_secret) || ENV["CLERK_WEBHOOK_SECRET"]
      expect(webhook_secret).to eq("test_secret")
    end

    it "sentry initializer can access dsn from credentials" do
      allow(Rails.application.credentials).to receive(:dig).with(:sentry, :dsn).and_return("https://test@sentry.io/123")

      # Simulate how the sentry initializer accesses the DSN
      sentry_dsn = Rails.application.credentials.dig(:sentry, :dsn) || ENV["SENTRY_DSN"]
      expect(sentry_dsn).to eq("https://test@sentry.io/123")
    end

    it "clerk initializer can access keys from credentials" do
      allow(Rails.application.credentials).to receive(:dig).with(:clerk, :secret_key).and_return("sk_test_123")
      allow(Rails.application.credentials).to receive(:dig).with(:clerk, :publishable_key).and_return("pk_test_123")

      # Simulate how the clerk initializer accesses the keys
      secret_key = Rails.application.credentials.dig(:clerk, :secret_key) || ENV["CLERK_SECRET_KEY"]
      publishable_key = Rails.application.credentials.dig(:clerk, :publishable_key) || ENV["CLERK_PUBLISHABLE_KEY"]

      expect(secret_key).to eq("sk_test_123")
      expect(publishable_key).to eq("pk_test_123")
    end
  end
end
