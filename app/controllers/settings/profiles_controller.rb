# frozen_string_literal: true

class Settings::ProfilesController < InertiaController
  before_action :set_user

  def show
    # Profile data comes from Clerk, this page can show read-only info
    # or redirect to Clerk's user profile management
  end

  def update
    # Profile updates should be handled by Clerk
    # Redirect to Clerk's profile management or show an informational message
    redirect_to settings_profile_path, notice: "Please update your profile through your account settings"
  end

  private

  def set_user
    @user = Current.user
  end
end
