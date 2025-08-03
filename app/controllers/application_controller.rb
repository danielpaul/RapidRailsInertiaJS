# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_request_details
  before_action :authenticate

  private

  def authenticate
    redirect_to sign_in_path unless perform_authentication
  end

  def require_no_authentication
    return unless perform_authentication

    flash[:notice] = "You are already signed in"
    redirect_to root_path
  end

  def perform_authentication
    # For testing, check if we have a test session
    if Rails.env.test? && Current.session
      return true
    end
    
    # First check if we have a Clerk session token
    clerk_session_token = cookies[:__session] || request.headers['Authorization']&.sub(/^Bearer /, '')
    
    return false unless clerk_session_token

    begin
      # For testing, accept mock tokens
      if Rails.env.test? && clerk_session_token.start_with?('mock_clerk_session_')
        clerk_user_id = clerk_session_token.sub('mock_clerk_session_', '')
        user = User.find_by(clerk_id: clerk_user_id)
        return false unless user
        
        Current.session ||= user.sessions.first || user.sessions.create!(
          user_agent: request.user_agent,
          ip_address: request.ip
        )
        return true
      end

      # Verify the session with Clerk (production/development)
      session_data = verify_clerk_session(clerk_session_token)
      return false unless session_data&.dig('user_id')

      # Find or create the user based on Clerk ID
      clerk_user_id = session_data['user_id']
      user = User.find_or_create_by(clerk_id: clerk_user_id)
      
      # Create or find a local session for tracking
      Current.session = user.sessions.find_or_create_by(
        user_agent: request.user_agent,
        ip_address: request.ip
      )
      
      true
    rescue => e
      Rails.logger.error("Clerk authentication failed: #{e.message}")
      false
    end
  end

  private

  def verify_clerk_session(session_token)
    Clerk::SDK.new.sessions.verify_session(session_token)
  rescue Clerk::Errors::Base => e
    Rails.logger.error("Failed to verify Clerk session: #{e.message}")
    nil
  rescue => e
    Rails.logger.error("Unexpected error verifying Clerk session: #{e.message}")
    nil
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end
