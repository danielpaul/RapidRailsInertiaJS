# frozen_string_literal: true

# Test controller to verify Sentry error tracking
# Only available in development and test environments for safety
class SentryTestController < ApplicationController
  # Only allow in non-production environments
  before_action :ensure_non_production!

  def test_backend_error
    # This will trigger a backend error for Sentry testing
    raise StandardError, "Test error from Rails backend - this should be captured by Sentry in production"
  end

  def test_frontend_error
    # Render a page that will trigger a frontend error
    render inertia: "SentryTest", props: { 
      test_type: "frontend_error",
      message: "This page will trigger a frontend error for Sentry testing"
    }
  end

  def test_performance
    # Test performance monitoring
    sleep(0.5) # Simulate some work
    render inertia: "SentryTest", props: {
      test_type: "performance",
      message: "This tests performance monitoring"
    }
  end

  private

  def ensure_non_production!
    if Rails.env.production?
      redirect_to root_path, alert: "Sentry testing is not available in production"
    end
  end
end