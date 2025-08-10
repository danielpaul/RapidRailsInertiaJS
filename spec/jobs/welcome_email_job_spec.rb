# frozen_string_literal: true

require "rails_helper"

RSpec.describe WelcomeEmailJob, type: :job do
  describe "#perform" do
    let(:user_email) { "test@example.com" }
    let(:user_name) { "Test User" }
    let(:mailer_double) { instance_double(ActionMailer::MessageDelivery) }
    
    before do
      allow(UserMailer).to receive(:welcome_email).and_return(mailer_double)
      allow(mailer_double).to receive(:deliver_now)
    end

    it "sends welcome email and returns result" do
      job = described_class.new
      
      expect(Rails.logger).to receive(:info).with("Sending welcome email to #{user_email}")
      expect(Rails.logger).to receive(:info).with("User name: #{user_name}")
      expect(Rails.logger).to receive(:info).with("Welcome email sent successfully to #{user_email}")
      
      expect(UserMailer).to receive(:welcome_email).with(user_email, user_name).and_return(mailer_double)
      expect(mailer_double).to receive(:deliver_now)
      
      result = job.perform(user_email, user_name)
      
      expect(result).to include(
        email: user_email,
        name: user_name,
        status: "delivered"
      )
      expect(result[:sent_at]).to be_within(1.second).of(Time.current)
    end

    it "handles missing user name gracefully" do
      job = described_class.new
      
      expect(Rails.logger).to receive(:info).with("Sending welcome email to #{user_email}")
      expect(Rails.logger).to receive(:info).with("Welcome email sent successfully to #{user_email}")
      
      expect(UserMailer).to receive(:welcome_email).with(user_email, nil).and_return(mailer_double)
      expect(mailer_double).to receive(:deliver_now)
      
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
