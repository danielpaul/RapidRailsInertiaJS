# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Email Configuration" do
  describe "Environment configurations" do
    it "configures letter_opener for development" do
      Rails.env = "development"
      Rails.application.reload_routes!
      expect(Rails.application.config.action_mailer.delivery_method).to eq(:letter_opener)
    end

    it "configures test delivery method for test environment" do
      expect(Rails.application.config.action_mailer.delivery_method).to eq(:test)
    end
  end

  describe "ApplicationMailer" do
    it "uses configurable from email address" do
      ENV["FROM_EMAIL"] = "test@example.com"
      expect(ApplicationMailer.default[:from]).to eq("test@example.com")
    end

    it "falls back to default from email when ENV not set" do
      ENV.delete("FROM_EMAIL")
      expect(ApplicationMailer.default[:from]).to eq("noreply@example.com")
    end
  end

  describe "UserMailer" do
    let(:user) { double("User", email: "user@example.com", generate_token_for: "token123") }

    describe "#password_reset" do
      it "sets correct recipient and subject" do
        mail = UserMailer.with(user: user).password_reset
        expect(mail.to).to eq(["user@example.com"])
        expect(mail.subject).to eq("Reset your password")
      end

      it "uses configured from address" do
        ENV["FROM_EMAIL"] = "custom@example.com"
        mail = UserMailer.with(user: user).password_reset
        expect(mail.from).to eq(["custom@example.com"])
      end
    end

    describe "#email_verification" do
      it "sets correct recipient and subject" do
        mail = UserMailer.with(user: user).email_verification
        expect(mail.to).to eq(["user@example.com"])
        expect(mail.subject).to eq("Verify your email")
      end

      it "uses configured from address" do
        ENV["FROM_EMAIL"] = "verify@example.com"
        mail = UserMailer.with(user: user).email_verification
        expect(mail.from).to eq(["verify@example.com"])
      end
    end
  end
end
