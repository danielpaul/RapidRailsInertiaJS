# frozen_string_literal: true

require "rails_helper"

RSpec.describe WelcomeEmailJob, type: :job do
  describe "#perform" do
    it "logs welcome email processing and returns result" do
      user_email = "test@example.com"
      user_name = "Test User"
      
      # Create an instance to test the logic directly
      job = described_class.new
      
      expect(Rails.logger).to receive(:info).with("📧 Sending welcome email to #{user_email}")
      expect(Rails.logger).to receive(:info).with("👤 User name: #{user_name}")
      expect(Rails.logger).to receive(:info).with("✅ Welcome email sent successfully to #{user_email}")
      
      result = job.perform(user_email, user_name)
      
      expect(result).to include(
        email: user_email,
        name: user_name,
        status: "delivered"
      )
      expect(result[:sent_at]).to be_within(1.second).of(Time.current)
    end

    it "handles missing user name gracefully" do
      user_email = "test@example.com"
      
      # Create an instance to test the logic directly
      job = described_class.new
      
      expect(Rails.logger).to receive(:info).with("📧 Sending welcome email to #{user_email}")
      expect(Rails.logger).to receive(:info).with("✅ Welcome email sent successfully to #{user_email}")
      
      result = job.perform(user_email)
      
      expect(result).to include(
        email: user_email,
        name: nil,
        status: "delivered"
      )
      expect(result[:sent_at]).to be_within(1.second).of(Time.current)
    end
    
    it "can be enqueued with perform_later" do
      user_email = "test@example.com"
      user_name = "Test User"
      
      expect {
        WelcomeEmailJob.perform_later(user_email, user_name)
      }.to have_enqueued_job(WelcomeEmailJob).with(user_email, user_name)
    end
  end
end
