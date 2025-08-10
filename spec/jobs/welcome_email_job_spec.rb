# frozen_string_literal: true

require "rails_helper"

RSpec.describe WelcomeEmailJob, type: :job do
  describe "#perform" do
    it "logs welcome email processing" do
      user_email = "test@example.com"
      user_name = "Test User"
      
      # Create an instance to test the logic directly
      job = described_class.new
      
      expect(Rails.logger).to receive(:info).with("Sending welcome email to #{user_email}")
      expect(Rails.logger).to receive(:info).with("User name: #{user_name}")
      expect(Rails.logger).to receive(:info).with("Welcome email sent successfully to #{user_email}")
      
      # Mock sleep to speed up test
      expect(job).to receive(:sleep).with(2)
      
      job.perform(user_email, user_name)
    end

    it "handles missing user name gracefully" do
      user_email = "test@example.com"
      
      # Create an instance to test the logic directly
      job = described_class.new
      
      expect(Rails.logger).to receive(:info).with("Sending welcome email to #{user_email}")
      expect(Rails.logger).to receive(:info).with("Welcome email sent successfully to #{user_email}")
      
      # Mock sleep to speed up test
      expect(job).to receive(:sleep).with(2)
      
      job.perform(user_email)
    end
  end
end
