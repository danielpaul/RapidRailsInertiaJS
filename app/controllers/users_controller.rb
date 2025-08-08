# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def destroy_current
    begin
      # Delete user from Clerk first
      clerk_sdk = Clerk::SDK.new
      clerk_sdk.users.delete_user(current_user.clerk_id)
    rescue Clerk::Errors::Base => e
      Rails.logger.error("Failed to delete Clerk user #{current_user.clerk_id}: #{e.message}")
      # Continue with local deletion even if Clerk deletion fails
    end

    # Delete user from our database
    current_user.destroy!
    
    # Redirect to home since user is now deleted
    redirect_to root_path
  end
end