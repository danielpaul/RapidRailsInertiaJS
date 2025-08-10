# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def password_reset
    @user = params[:user]
    @signed_id = @user.generate_token_for(:password_reset)
    @email_title = "Reset your password"

    mail to: @user.email, subject: "Reset your password"
  end

  def email_verification
    @user = params[:user]
    @signed_id = @user.generate_token_for(:email_verification)
    @email_title = "Verify your email"

    mail to: @user.email, subject: "Verify your email"
  end
end
