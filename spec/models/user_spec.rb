# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "validates presence of clerk_id" do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors[:clerk_id]).to include("can't be blank")
    end

    it "validates uniqueness of clerk_id" do
      User.create!(clerk_id: "test_id")
      user = User.new(clerk_id: "test_id")
      expect(user).not_to be_valid
      expect(user.errors[:clerk_id]).to include("has already been taken")
    end
  end

  describe "welcome email callback" do
    it "sends welcome email after user creation when email is present" do
      user = User.new(clerk_id: "new_user_id")
      
      # Mock the email method to return an email
      allow(user).to receive(:email).and_return("test@example.com")
      
      # Expect the welcome email to be delivered
      expect(UserMailer).to receive(:welcome_email).with(user).and_call_original
      expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)
      
      user.save!
    end

    it "does not send welcome email when user has no email" do
      user = User.new(clerk_id: "new_user_id")
      
      # Mock the email method to return nil
      allow(user).to receive(:email).and_return(nil)
      
      # Expect no email to be sent
      expect(UserMailer).not_to receive(:welcome_email)
      
      user.save!
    end
  end

  describe "#name" do
    it "returns 'Test User' in test environment" do
      user = User.new(clerk_id: "test_id")
      expect(user.name).to eq("Test User")
    end
  end

  describe "#email" do
    it "returns 'test@example.com' in test environment" do
      user = User.new(clerk_id: "test_id")
      expect(user.email).to eq("test@example.com")
    end
  end
end