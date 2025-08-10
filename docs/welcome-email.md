# Welcome Email Documentation

## Overview

The welcome email system automatically sends a responsive, professionally designed email to new users when their account is created. The email supports both light and dark modes and is optimized for email client compatibility.

## Features

- **Responsive Design**: Works across desktop and mobile email clients
- **Dark/Light Mode Support**: Automatically adapts to user's preferred color scheme
- **Email Client Compatibility**: Uses table-based layouts for maximum compatibility
- **Multiple Formats**: Both HTML and text versions included
- **Template Options**: Available in both ERB and HAML formats
- **Environment Configuration**: Customizable URLs and contact information

## Configuration

### Environment Variables

Set these environment variables to customize the email content:

```bash
# Application URL for call-to-action button
APP_URL=https://your-app.com

# Support email for help links
SUPPORT_EMAIL=support@your-app.com

# From email address (configured in ApplicationMailer)
FROM_EMAIL=welcome@your-app.com
```

### Email Delivery

The welcome email is automatically sent when a new User record is created, provided the user has an email address. The email is sent asynchronously using `deliver_later` to avoid blocking the user registration process.

## Files Structure

```
app/
├── mailers/
│   ├── user_mailer.rb                    # UserMailer class with welcome_email method
│   └── previews/
│       └── user_mailer_preview.rb        # Email preview for development
├── models/
│   └── user.rb                           # User model with after_create callback
└── views/
    └── user_mailer/
        ├── welcome_email.html.erb        # HTML email template (ERB)
        ├── welcome_email.html.haml       # HTML email template (HAML)
        ├── welcome_email.text.erb        # Text email template (ERB)
        └── welcome_email.text.haml       # Text email template (HAML)
```

## Development and Testing

### Email Previews

During development, you can preview the welcome email by visiting:
```
http://localhost:3000/rails/mailers/user_mailer/welcome_email
```

This allows you to see how the email will look without actually sending it.

### Testing

Run the test suite to verify the welcome email functionality:

```bash
bundle exec rspec spec/mailers/email_configuration_spec.rb
bundle exec rspec spec/models/user_spec.rb
```

## Customization

### Styling

The email uses inline CSS for maximum email client compatibility. Key style classes include:

- `.dark-mode-*`: Styles for dark mode
- `.light-mode-*`: Styles for light mode  
- `.mobile-*`: Responsive styles for mobile devices
- `.button`: Call-to-action button styling

### Content

To modify the email content, edit the template files in `app/views/user_mailer/`. The templates support both ERB and HAML formats.

### Adding New Email Types

To add additional email types to the UserMailer:

1. Add a new method to `app/mailers/user_mailer.rb`
2. Create corresponding template files in `app/views/user_mailer/`
3. Add preview methods to `app/mailers/previews/user_mailer_preview.rb`
4. Add tests to the mailer specs

## Technical Details

### Email Client Compatibility

The email templates use several techniques for maximum compatibility:

- Table-based layouts instead of CSS Grid/Flexbox
- Inline CSS instead of external stylesheets
- MSO-specific CSS for Outlook compatibility
- Progressive enhancement for dark mode support

### Responsive Design

The email includes media queries for:

- Mobile devices (max-width: 640px)
- Dark mode preference detection
- High DPI displays

### Security

- All user input is properly escaped in templates
- Email addresses are validated before sending
- Environment variables are used for sensitive configuration