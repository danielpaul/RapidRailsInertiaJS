# frozen_string_literal: true

class SessionsController < InertiaController
  skip_before_action :authenticate_user!, only: %i[ new create switch ]

  def new
    if user_signed_in?
      flash[:notice] = "You are already signed in"
      redirect_to root_path
    end
  end

  def switch
    if user_signed_in?
      flash[:notice] = "You are already signed in"
      redirect_to root_path
    end
  end

  def create
    # This endpoint will handle Clerk token posting from frontend
    clerk_token = params[:clerk_token]

    if clerk_token.present?
      # Store the clerk token as session - this will be the exact token from frontend
      session[:clerk_token] = clerk_token
      render json: { success: true }
    else
      render json: { error: "Invalid token" }, status: :unprocessable_entity
    end
  end

  def destroy
    session[:clerk_token] = nil
    # Clear Clerk session cookie
    cookies.delete(:__session, domain: :all)
    redirect_to root_path, notice: "Signed out successfully", inertia: {clear_history: true}
  end
end
