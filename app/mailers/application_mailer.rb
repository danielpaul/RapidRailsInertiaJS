# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
  
  # Include email helpers for all mailers
  helper EmailHelper
end
