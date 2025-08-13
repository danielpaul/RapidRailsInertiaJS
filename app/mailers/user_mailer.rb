# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @app_name = AppConstants::APP_NAME
    
    mail(
      to: @user.email,
      subject: "Welcome to #{@app_name}!"
    )
  end
end