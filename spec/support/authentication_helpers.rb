# frozen_string_literal: true

module AuthenticationHelpers
  extend ActiveSupport::Concern

  def sign_in_as(user)
    # Generate a realistic Clerk session token
    session_token = "sess_#{SecureRandom.hex(16)}"
    
    # Set the __session cookie that Clerk would provide
    if defined?(cookies)
      cookies[:__session] = session_token
    end
    
    # Mock the Clerk SDK to return the user's clerk_id
    allow_any_instance_of(Clerk::SDK).to receive(:verify_token).and_return(
      { "sub" => user.clerk_id }
    )
    
    # Mock the request environment to simulate Clerk middleware
    allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(
      double("clerk_proxy", 
        user?: true, 
        user_id: user.clerk_id,
        organization_id: nil
      )
    )
  end

  def sign_out
    # Remove the __session cookie
    if defined?(cookies)
      cookies.delete(:__session)
    end
    
    # Reset any Clerk SDK mocks
    RSpec::Mocks.space.proxy_for(Clerk::SDK).reset if defined?(RSpec::Mocks)
  end

  def mock_clerk_session(user_id, session_token = nil)
    session_token ||= "sess_#{SecureRandom.hex(16)}"
    
    if defined?(cookies)
      cookies[:__session] = session_token
    end
    
    allow_any_instance_of(Clerk::SDK).to receive(:verify_token).and_return(
      double("session", user_id: user_id)
    )
    
    session_token
  end

  def mock_clerk_error(error_class, message = "Test error")
    allow_any_instance_of(Clerk::SDK).to receive(:verify_token).and_raise(
      error_class.new(message)
    )
  end
end
