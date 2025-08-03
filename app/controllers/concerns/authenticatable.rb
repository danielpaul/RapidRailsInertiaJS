# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern
  include Clerk::Authenticatable

  included do
    helper_method :current_user, :user_signed_in?, :current_org if respond_to?(:helper_method)
  end

  private

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless user_signed_in?
  end
  alias require_clerk_session! authenticate_user!

  def current_user
    return @current_user if defined?(@current_user)

    if Rails.env.development? && request.headers["Authorization"]&.start_with?("Bearer DEV_BYPASS_TOKEN:")
      user_id = request.headers["Authorization"].split(":").last
      @current_user = User.find_by(id: user_id)
      # Set up session for dev bypass
      if @current_user
        Current.session ||= @current_user.sessions.first || @current_user.sessions.create!(
          user_agent: request.user_agent,
          ip_address: request.ip
        )
      end
    elsif Rails.env.test? && Current.session
      # Test environment: use Current.session if available
      @current_user = Current.session.user
    elsif !Rails.env.test? && (user_id = clerk.user_id)
      @current_user = User.find_or_create_by(clerk_id: user_id)
      # Set up session tracking
      if @current_user
        Current.session = @current_user.sessions.find_or_create_by(
          user_agent: request.user_agent,
          ip_address: request.ip
        )
      end
    else
      @current_user = nil
    end
  end

  def clerk_user
    # NOTE: This makes an additional request and attempts to cache it.
    return nil if Rails.env.test?
    clerk.user
  end

  def user_signed_in?
    current_user.present?
  end

  def current_org
    return @current_org if defined?(@current_org)

    if !Rails.env.test? && (org_id = clerk.organization_id)
      @current_org = Org.find_or_create_by(clerk_org_id: org_id)
    else
      @current_org = nil
    end
  end

  def org_account?
    current_org.present?
  end

  def current_user_org_role
    if org_account? && !Rails.env.test?
      clerk.organization_role
    else
      nil
    end
  end
end