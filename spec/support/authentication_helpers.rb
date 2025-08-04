# frozen_string_literal: true

module AuthenticationHelpers
  extend ActiveSupport::Concern

  def sign_in_as(user)
    session = user.sessions.create!
    Current.session = session
    
    # Mock Clerk session cookie for tests
    if defined?(cookies)
      cookies[:__session] = "mock_clerk_session_#{user.clerk_id}"
    end
  end

  def sign_out
    Current.session = nil
    if defined?(cookies)
      cookies.delete(:__session)
    end
  end
end
