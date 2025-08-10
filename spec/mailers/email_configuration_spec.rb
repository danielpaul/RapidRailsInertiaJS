# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Email Configuration" do
  describe "ApplicationMailer" do
    around(:each) do |example|
      original_from_email = ENV["FROM_EMAIL"]
      example.run
      if original_from_email
        ENV["FROM_EMAIL"] = original_from_email
      else
        ENV.delete("FROM_EMAIL")
      end
    end

    it "uses configurable from email address" do
      ENV["FROM_EMAIL"] = "test@example.com"
      # Since we use a proc, we need to call it to get the value
      expect(ApplicationMailer.default[:from].call).to eq("test@example.com")
    end

    it "falls back to default from email when ENV not set" do
      ENV.delete("FROM_EMAIL")
      # Since we use a proc, we need to call it to get the value
      expect(ApplicationMailer.default[:from].call).to eq("noreply@example.com")
    end
  end

  describe "UserMailer" do
    let(:user) { double("User", email: "user@example.com", generate_token_for: "token123") }

    around(:each) do |example|
      original_from_email = ENV["FROM_EMAIL"]
      example.run
      if original_from_email
        ENV["FROM_EMAIL"] = original_from_email
      else
        ENV.delete("FROM_EMAIL")
      end
    end
  end
end
