# Inertia Rails Starter Kit

A modern full-stack starter application with Rails backend and React frontend using Inertia.js based on the [Laravel Starter Kit](https://github.com/laravel/react-starter-kit) and [Inertia Rails Starter Kit](https://github.com/inertia-rails/react-starter-kit).

## Features

- [Inertia Rails](https://inertia-rails.dev) & [Vite Rails](https://vite-ruby.netlify.app) setup
- [React](https://react.dev) frontend with TypeScript & [shadcn/ui](https://ui.shadcn.com) component library
- [Clerk](https://clerk.com) User authentication system
- Email delivery with [Postmark](https://postmarkapp.com) (production) and [letter_opener](https://github.com/ryanb/letter_opener) (development)
- [Kamal](https://kamal-deploy.org/) for deployment
- Optional SSR support

## Setup

1. Clone this repository
2. Set up environment variables (see [Environment Variables](#environment-variables))
3. Setup dependencies & run the server:
   ```bash
   bin/setup
   ```
4. Open http://localhost:3000

## Environment Variables

This application requires the following environment variables for proper functionality:

### Required for Development & Production

#### Clerk Authentication
- `VITE_CLERK_PUBLISHABLE_KEY` - Your Clerk publishable key (starts with `pk_test_` or `pk_live_`)
  - Get this from your [Clerk Dashboard](https://dashboard.clerk.com)
  - Add to your `.env` file for development
  - Required for frontend authentication components

#### Rails Credentials
The following secrets should be added to Rails encrypted credentials using `rails credentials:edit`:
```yaml
clerk:
  api_key: "sk_test_your_secret_key_here"  # Your Clerk secret key

# For production email delivery
postmark:
  api_token: "your_postmark_server_api_token_here"
```

#### Email Delivery
- `FROM_EMAIL` - Email address used as sender for all outgoing emails
  - Must be verified in your Postmark account for production
  - Default: `noreply@example.com`
- `HOST` - Your application's domain name for generating links in emails (production)

**Email Setup:** This application uses **Postmark** for production email delivery and **letter_opener** for development email preview.

**Development:** No setup required - emails automatically open in your browser.

**Production Setup:**
1. Sign up for a [Postmark account](https://postmarkapp.com/) and create a server
2. Add your Postmark API token to Rails credentials:
   ```bash
   rails credentials:edit
   ```
   Add:
   ```yaml
   postmark:
     api_token: "your_postmark_server_api_token_here"
   ```
3. Set environment variables:
   ```bash
   FROM_EMAIL=noreply@yourdomain.com
   HOST=yourdomain.com
   ```
4. Verify the sender signature in your Postmark account


### Optional Environment Variables

#### Database
- `DATABASE_URL` - PostgreSQL connection string (production)
- Default: SQLite in development

#### Rails
- `RAILS_ENV` - Application environment (`development`, `test`, `production`)
- `SECRET_KEY_BASE` - Rails secret key base (auto-generated in development)

#### Deployment (Kamal)
- `KAMAL_REGISTRY_PASSWORD` - Docker registry password
- `KAMAL_REGISTRY_USERNAME` - Docker registry username
- Server-specific variables as configured in `config/deploy.yml`

### Setting Up Clerk

1. Create a [Clerk account](https://clerk.com)
2. Create a new application in your Clerk dashboard
3. Copy the publishable key to `VITE_CLERK_PUBLISHABLE_KEY` in your `.env` file
4. Copy the secret key to Rails credentials using `rails credentials:edit`
5. Configure your Clerk application settings (sign-in methods, appearance, etc.)

### Setting Up Clerk Webhooks

This application uses Clerk webhooks to automatically sync user data changes. To set up webhooks:

1. In your Clerk dashboard, go to **Webhooks**
2. Create a new webhook endpoint with the URL: `https://your-domain.com/webhooks/clerk`
3. Select the following events:
   - `user.deleted` - Automatically deletes users from your database when deleted in Clerk
   - `user.updated` - Clears user cache when profile is updated in Clerk
4. Copy the webhook signing secret to Rails credentials:
   ```bash
   rails credentials:edit
   ```
   Add the webhook secret:
   ```yaml
   clerk:
     api_key: "sk_test_your_secret_key_here"
     webhook_secret: "whsec_your_webhook_secret_here"
   ```

**Note:** The webhook endpoint automatically handles user deletion from your platform when users delete their accounts through Clerk's user interface, eliminating the need for manual account deletion components.

### Example .env file

```bash
# Clerk Configuration
VITE_CLERK_PUBLISHABLE_KEY=pk_test_your_publishable_key_here

# Email Configuration (production)
# FROM_EMAIL=noreply@yourdomain.com
# HOST=yourdomain.com

# Optional: Database (defaults to SQLite in development)
# DATABASE_URL=postgresql://user:password@localhost/myapp_development
```

## Enabling SSR

This starter kit comes with optional SSR support. To enable it, follow these steps:

1. Open `app/frontend/entrypoints/inertia.ts` and uncomment part of the `setup` function:
   ```ts
   // Uncomment the following to enable SSR hydration:
   // if (el.hasChildNodes()) {
   //   hydrateRoot(el, createElement(App, props))
   //   return
   // }
   ```
2. Open `config/deploy.yml` and uncomment several lines:
   ```yml
   servers:
     # Uncomment to enable SSR:
     # vite_ssr:
     #   hosts:
     #     - 192.168.0.1
     #   cmd: bundle exec vite ssr
     #   options:
     #     network-alias: vite_ssr
      
   # ...
      
   env:
     clear:
       # Uncomment to enable SSR:
       # INERTIA_SSR_ENABLED: true
       # INERTIA_SSR_URL: "http://vite_ssr:13714"
      
   # ...
      
   builder:
     # Uncomment to enable SSR:
     # dockerfile: Dockerfile-ssr
   ```
   
That's it! Now you can deploy your app with SSR support.

## License

The project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
