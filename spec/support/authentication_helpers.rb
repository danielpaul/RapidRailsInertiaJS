# frozen_string_literal: true

module AuthenticationHelpers
  extend ActiveSupport::Concern

  def sign_in_as(user)
    session = user.sessions.create!
    Current.session = session
    
    # Set the authorization header for development bypass in test environment
    if defined?(request) && request.respond_to?(:headers)
      request.headers["Authorization"] = "Bearer DEV_BYPASS_TOKEN:#{user.id}"
    end
    
    # Also mock Clerk session cookie for backward compatibility
    if defined?(cookies)
      cookies[:__session] = "mock_clerk_session_#{user.clerk_id}"
    end
  end

  def sign_out
    Current.session = nil
    if defined?(request) && request.respond_to?(:headers)
      request.headers.delete("Authorization")
    end
    if defined?(cookies)
      cookies.delete(:__session)
    end
  end
end
