# frozen_string_literal: true

class SessionsController < InertiaController
  skip_before_action :authenticate_user!, only: %i[ new create switch ]
  before_action :require_no_authentication, only: %i[ new create switch ]

  def new
    # This will render the sign-in page with Clerk components
  end

  def switch
    # This will render the account switching page with Clerk components
  end

  def destroy
    Current.session = nil
    # Clear Clerk session cookie
    cookies.delete(:__session, domain: :all)
    redirect_to root_path, notice: "Signed out successfully", inertia: {clear_history: true}
  end
end
