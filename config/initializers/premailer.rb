# frozen_string_literal: true

# Configure Premailer for automatic CSS inlining in email templates
Premailer::Rails.config.merge!(
  generate_text_part: false, # Don't auto-generate text parts
  remove_ids: true, # Remove IDs from HTML for better email client compatibility
  remove_classes: false, # Keep classes for debugging/future use
  remove_comments: true, # Remove HTML comments
  preserve_styles: true, # Keep any existing inline styles
  include_link_tags: true, # Include CSS from <link> tags
  include_style_tags: true, # Include CSS from <style> tags
  css_to_attributes: true, # Convert CSS to HTML attributes where possible
  strategies: [:filesystem, :network] # How to load external CSS files
)