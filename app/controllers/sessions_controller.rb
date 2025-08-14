# frozen_string_literal: true

class SessionsController < InertiaController
  skip_before_action :authenticate_user!, only: %i[ new create sign_up create_signup ]

  def new
    if user_signed_in?
      flash[:notice] = "You are already signed in"
      redirect_to root_path
    end
  end

  def create
    # Handle Clerk token and create Rails session
    clerk_token = params[:clerk_token]

    if clerk_token.present?
      # The token verification is handled by the Clerk middleware
      # If we reach here, the user is authenticated
      head :ok
    else
      head :unauthorized
    end
  end

  def sign_up
    if user_signed_in?
      flash[:notice] = "You are already signed in"
      redirect_to root_path
    end
  end

  def create_signup
    # Handle Clerk token and create Rails session for sign-up
    clerk_token = params[:clerk_token]

    if clerk_token.present?
      # The token verification is handled by the Clerk middleware
      # If we reach here, the user is authenticated
      head :ok
    else
      head :unauthorized
    end
  end

  def switch
    # renders the account selector page
  end
end
