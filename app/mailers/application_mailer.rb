# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: -> { AppConstants::FROM_EMAIL }
  layout "mailer"
end
