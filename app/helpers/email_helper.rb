# frozen_string_literal: true

module EmailHelper
  # Renders an email header with title and optional subtitle
  def email_header(title, subtitle: nil)
    render "shared/email_components/header", title: title, subtitle: subtitle
  end

  # Renders a primary action button
  def email_button(text, url)
    render "shared/email_components/button", text: text, url: url
  end

  # Renders a secondary action button
  def email_button_secondary(text, url)
    render "shared/email_components/button_secondary", text: text, url: url
  end

  # Renders email footer with optional unsubscribe link
  def email_footer(unsubscribe_url: nil)
    render "shared/email_components/footer", unsubscribe_url: unsubscribe_url
  end

  # Helper to generate consistent email titles
  def email_title(subject)
    @email_title = subject
  end
end