# Email Configuration Setup

This application is configured to use **Postmark** for production email delivery and **letter_opener** for development email preview.

## Development Setup

Development is already configured to use `letter_opener` which will open emails in your browser instead of sending them.

The configuration is in `config/environments/development.rb`:
```ruby
config.action_mailer.delivery_method = :letter_opener
```

No additional setup is required for development.

## Production Setup

### 1. Install Dependencies

Run `bundle install` to install the `postmark-rails` gem.

### 2. Get Postmark API Token

1. Sign up for a [Postmark account](https://postmarkapp.com/)
2. Create a new server or use an existing one
3. Copy your **Server API Token** from the server settings

### 3. Configure Credentials

Add your Postmark API token to Rails credentials:

```bash
EDITOR="code --wait" rails credentials:edit
```

Add the following structure:
```yaml
postmark:
  api_token: your_postmark_server_api_token_here
```

### 4. Set Environment Variables

Set the following environment variables in your production environment:

- `FROM_EMAIL`: The email address that emails will be sent from (must be verified in Postmark)
- `HOST`: Your application's domain name for generating links in emails

Example:
```bash
FROM_EMAIL=noreply@yourdomain.com
HOST=yourdomain.com
```

### 5. Verify Sender Signature

In your Postmark account, verify the sender signature for the email address you'll be using in `FROM_EMAIL`.

## Testing the Configuration

### Development Testing

1. Start your Rails server: `rails server`
2. Trigger an email (e.g., password reset)
3. The email will open in your browser automatically

### Production Testing

1. Deploy your application with the credentials and environment variables set
2. Trigger an email in production
3. Check your Postmark dashboard for delivery status
4. Verify the recipient receives the email

## Mailer Methods Available

The application includes the following mailer methods:

- `UserMailer.password_reset` - Sends password reset emails
- `UserMailer.email_verification` - Sends email verification emails

## Troubleshooting

### Common Issues

1. **"401 Unauthorized" errors**: Check that your Postmark API token is correct
2. **"422 Unprocessable Entity" errors**: Verify your sender signature in Postmark
3. **Emails not delivering**: Check Postmark's activity log for bounce/spam information

### Testing Credentials

You can test if credentials are properly configured:

```ruby
Rails.application.credentials.dig(:postmark, :api_token)
```

This should return your API token (don't log this in production!).

## Configuration Files

- `config/environments/development.rb` - Development email configuration
- `config/environments/production.rb` - Production email configuration  
- `config/environments/test.rb` - Test email configuration
- `app/mailers/application_mailer.rb` - Base mailer configuration
- `config/credentials.yml.example` - Example credentials structure