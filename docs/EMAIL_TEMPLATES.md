# Email Template System

This project uses a modernized email template system with the following features:

## Features

- **HAML Templates**: Clean, readable syntax for email templates
- **Reusable Components**: Modular email components in `app/views/shared/email_components/`
- **Tailwind CSS**: Utility-first CSS styling
- **Automated CSS Inlining**: CSS is automatically inlined for better email client compatibility
- **Responsive Design**: Mobile-friendly email layouts

## Migration from ERB

The old ERB templates have been replaced with HAML templates that provide:
- Better readability and maintainability
- Component-based architecture
- Consistent styling with Tailwind CSS
- Automated CSS inlining for email client compatibility

## Installation

After cloning, install the required gems:

```bash
bundle install
```

The system will automatically:
- Configure Premailer for CSS inlining
- Set up HAML template engine
- Include email stylesheets in asset pipeline

## Components

### Header Component
```haml
= render "shared/email_components/header", title: "Email Title", subtitle: "Optional subtitle"
```

### Button Components
```haml
= render "shared/email_components/button", text: "Click Me", url: "https://example.com"
= render "shared/email_components/button_secondary", text: "Secondary Action", url: "https://example.com"
```

### Footer Component
```haml
= render "shared/email_components/footer", unsubscribe_url: "https://example.com/unsubscribe"
```

## Email Helper Methods

The `EmailHelper` module provides convenient methods:

```ruby
# In your mailer view
email_header("Reset Your Password", subtitle: "Security is important")
email_button("Reset Password", reset_url)
email_footer(unsubscribe_url: unsubscribe_url)
```

## Configuration

### CSS Styling
- Email styles are defined in `app/assets/stylesheets/email.css`
- Uses utility classes compatible with Tailwind CSS
- Automatically inlined by Premailer for email client compatibility

### Premailer Configuration
- Configured in `config/initializers/premailer.rb`
- Automatically converts CSS to inline styles
- Optimized for email client rendering

## Adding New Email Templates

1. Create HAML template in the appropriate mailer view directory
2. Use email components for consistent styling
3. Set `@email_title` in your mailer method
4. Create corresponding text template for accessibility

## Development

To preview emails in development:
- Use `letter_opener` gem (already included)
- Emails will open in browser when sent in development mode

## Example Template Structure

```haml
= email_header("Welcome!", subtitle: "Thanks for joining us")

.email-body
  %p.email-text Welcome to our platform!
  
  .text-center
    = email_button("Get Started", dashboard_url)

= email_footer
```

## Testing

To test email rendering:

```ruby
# In Rails console
UserMailer.with(user: User.first).email_verification.deliver_now
```

This will open the email in your browser (in development) showing the styled template with inlined CSS.