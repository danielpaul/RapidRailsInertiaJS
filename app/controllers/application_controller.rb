# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authenticatable
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_request_details
  before_action :authenticate_user!

  private

  def require_no_authentication
    return unless user_signed_in?

    flash[:notice] = "You are already signed in"
    redirect_to root_path
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end
