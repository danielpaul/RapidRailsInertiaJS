# frozen_string_literal: true

class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_email, user_name = nil)
    Rails.logger.info "Sending welcome email to #{user_email}"
    Rails.logger.info "User name: #{user_name}" if user_name.present?
    
    # Send the actual welcome email
    UserMailer.welcome_email(user_email, user_name).deliver_now
    
    Rails.logger.info "Welcome email sent successfully to #{user_email}"
    
    # Return a result that can be used in tests or callbacks
    {
      email: user_email,
      name: user_name,
      sent_at: Time.current,
      status: "delivered"
    }
  rescue => e
    Rails.logger.error "Failed to send welcome email to #{user_email}: #{e.message}"
    raise # Re-raise the exception so solid_queue can handle retries
  end
end
