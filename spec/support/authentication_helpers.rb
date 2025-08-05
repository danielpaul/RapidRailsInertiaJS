# frozen_string_literal: true

module AuthenticationHelpers
  extend ActiveSupport::Concern

  def sign_in_as(user)
    # Simulate clerk token in session for testing
    session[:clerk_token] = "test_token"
    
    # Mock Clerk session cookie for tests
    if defined?(cookies)
      cookies[:__session] = "mock_clerk_session_#{user.clerk_id}"
    end
  end

  def sign_out
    session[:clerk_token] = nil if defined?(session)
    if defined?(cookies)
      cookies.delete(:__session)
    end
  end
end
