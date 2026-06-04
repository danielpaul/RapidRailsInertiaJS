# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern
  include Clerk::Authenticatable

  included do
    helper_method :current_user, :user_signed_in?, :current_org if respond_to?(:helper_method)
  end

  private

  def authenticate_user!
    redirect_to sign_in_path unless user_signed_in?
  end
  alias require_clerk_session! authenticate_user!

  # Memoized per request; user/org/role are each resolved lazily on first access,
  # so requests that only need the user don't pay for an Org lookup.
  def clerk_auth
    @clerk_auth ||= ClerkAuthenticationResolver.call(clerk)
  end

  def current_user
    clerk_auth.user
  end

  def clerk_user
    # NOTE: This method should be mocked in tests
    return nil if Rails.env.test?
    clerk.user
  end

  def user_signed_in?
    current_user.present?
  end

  def current_org
    clerk_auth.org
  end
end
