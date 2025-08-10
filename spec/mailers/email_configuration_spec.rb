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
    let(:user) { double("User", email: "user@example.com", name: "John Doe") }

    around(:each) do |example|
      original_from_email = ENV["FROM_EMAIL"]
      example.run
      if original_from_email
        ENV["FROM_EMAIL"] = original_from_email
      else
        ENV.delete("FROM_EMAIL")
      end
    end

    describe "#welcome_email" do
      let(:mail) { UserMailer.welcome_email(user) }

      it "sends email to user's email address" do
        expect(mail.to).to eq(["user@example.com"])
      end

      it "has correct subject" do
        expect(mail.subject).to eq("Welcome to RapidRails!")
      end

      it "uses configured from email address" do
        ENV["FROM_EMAIL"] = "welcome@example.com"
        expect(mail.from).to eq(["welcome@example.com"])
      end

      it "includes user's name in the email body" do
        expect(mail.body.encoded).to include("John Doe")
      end

      it "includes welcome message in the email body" do
        expect(mail.body.encoded).to include("Welcome to RapidRails")
        expect(mail.body.encoded).to include("thrilled to have you join")
      end

      it "includes call-to-action button" do
        expect(mail.body.encoded).to include("Get Started Now")
      end

      it "has both HTML and text parts" do
        expect(mail.multipart?).to be true
        expect(mail.html_part).to be_present
        expect(mail.text_part).to be_present
      end
    end
  end
end
