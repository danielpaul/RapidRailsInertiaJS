# frozen_string_literal: true

# Preview emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    # Create a mock user for preview
    user = OpenStruct.new(
      name: "John Doe",
      email: "john.doe@example.com"
    )
    
    UserMailer.welcome_email(user)
  end

  def welcome_email_no_name
    # Create a mock user without a name for preview
    user = OpenStruct.new(
      name: nil,
      email: "user@example.com"
    )
    
    UserMailer.welcome_email(user)
  end
end