# frozen_string_literal: true

class SessionsController < InertiaController
  skip_before_action :authenticate, only: %i[ new create ]
  before_action :require_no_authentication, only: %i[ new create ]
  before_action :set_session, only: :destroy

  def new
    # This will render the sign-in page with Clerk components
  end

  def create
    # Clerk handles authentication on the frontend
    # This endpoint might not be needed, but keeping for compatibility
    redirect_to dashboard_path, notice: "Signed in successfully"
  end

  def destroy
    @session.destroy! if @session
    Current.session = nil
    # Clear Clerk session cookie
    cookies.delete(:__session, domain: :all)
    redirect_to root_path, notice: "Signed out successfully", inertia: {clear_history: true}
  end

  private

  def set_session
    @session = Current.session
  end
end
