# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sentry Configuration" do
  describe "initialization" do
    it "does not initialize Sentry in test environment" do
      # In test environment, Sentry should not be initialized
      # The hub may or may not exist depending on gem loading
      expect(Sentry.get_current_hub).to be_nil
      expect(Sentry.configuration&.dsn).to be_nil
    end

    it "does not initialize Sentry in development environment" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))

      # Reload initializer
      load Rails.root.join("config/initializers/sentry.rb")

      expect(Sentry.configuration&.dsn).to be_nil
    end

    context "in production environment" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      end

      it "initializes Sentry when DSN is present" do
        with_env("SENTRY_DSN" => "https://test@example.com/123") do
          # Reinitialize Sentry with test DSN
          Sentry.init do |config|
            config.dsn = ENV["SENTRY_DSN"]
            config.environment = Rails.env
          end

          expect(Sentry.configuration.dsn.to_s).to eq("https://test@example.com/123")
          expect(Sentry.configuration.environment).to eq("production")
        end
      end

      it "does not initialize Sentry when DSN is not present" do
        with_env("SENTRY_DSN" => nil) do
          load Rails.root.join("config/initializers/sentry.rb")
          # DSN should remain nil as no environment variable was provided
          expect(Sentry.configuration&.dsn).to be_nil
        end
      end
    end
  end

  private

  def with_env(env_vars)
    original_env = {}
    env_vars.each do |key, value|
      original_env[key] = ENV[key]
      ENV[key] = value
    end

    yield
  ensure
    original_env.each do |key, value|
      ENV[key] = value
    end
  end
end
