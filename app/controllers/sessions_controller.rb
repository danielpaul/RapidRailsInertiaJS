# frozen_string_literal: true

class SessionsController < InertiaController
  skip_before_action :authenticate_user!, only: %i[ new sign_up ]

  def new
    if user_signed_in?
      flash[:notice] = "You are already signed in"
      redirect_to root_path
    end
  end

  def sign_up
    if user_signed_in?
      flash[:notice] = "You are already signed in"
      redirect_to root_path
    end
  end

  def switch
    # renders the account selector page
  end
end
