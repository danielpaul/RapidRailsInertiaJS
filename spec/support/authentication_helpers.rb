# frozen_string_literal: true

module AuthenticationHelpers
  extend ActiveSupport::Concern

  def sign_in_as(user)
    session = user.sessions.create!
    Current.session = session
    
    # Mock Clerk session cookie for testing
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies[:__session] = "mock_clerk_session_#{user.clerk_id}"
  end

  def sign_out
    Current.session = nil
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies.delete(:__session)
  end
end
