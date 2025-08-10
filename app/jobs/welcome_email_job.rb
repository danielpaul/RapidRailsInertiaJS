# frozen_string_literal: true

class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_email, user_name = nil)
    # Simulate sending a welcome email
    Rails.logger.info "Sending welcome email to #{user_email}"
    Rails.logger.info "User name: #{user_name}" if user_name.present?
    
    # In a real application, you would send an actual email here
    # UserMailer.welcome_email(user_email, user_name).deliver_now
    
    # Simulate some processing time
    sleep(2)
    
    Rails.logger.info "Welcome email sent successfully to #{user_email}"
  end
end
