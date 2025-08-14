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

### Quick Start

1. **Clone this repository**
   ```bash
   git clone https://github.com/danielpaul/RapidRailsInertiaJS.git
   cd RapidRailsInertiaJS
   ```

2. **Run the setup script**
   ```bash
   bin/setup
   ```
   
   The setup script will:
   - Install Ruby and Node.js dependencies
   - Create `.env` file from `.env.example` (if not present)
   - Guide you through Rails credentials setup
   - Prepare the database
   - Start the development server

3. **Open http://localhost:3000**

### Setup Details

The `bin/setup` script handles most configuration automatically, but you'll need to configure:

#### 1. Environment Variables (.env file)
The setup script will create a `.env` file from `.env.example`. You need to:
- Add your Clerk publishable key: `VITE_CLERK_PUBLISHABLE_KEY=pk_test_your_key_here`
- Configure any other environment-specific settings

#### 2. Rails Credentials
The setup script will help you configure Rails encrypted credentials. You need to add:
- **Clerk secret key** for backend authentication
- **Postmark API token** for production email delivery

Run `bin/rails credentials:edit` to add:
```yaml
clerk:
  secret_key: "sk_test_your_secret_key_here"

# For production email delivery
postmark:
  api_token: "your_postmark_server_api_token_here"
```

**Credentials Troubleshooting:**
- If you have an existing encrypted credentials file but missing `master.key`, the setup script will guide you through recovery options
- If you need to start fresh, choose option 2 in the setup script to recreate credentials
- Use `config/credentials.yml.example` as a reference for the expected structure

### Manual Setup (Alternative)

If you prefer manual setup or encounter issues:

1. **Install dependencies:**
   ```bash
   bundle install
   npm install
   ```

2. **Create environment file:**
   ```bash
   cp .env.example .env
   # Edit .env to add your environment variables
   ```

3. **Setup Rails credentials:**
   ```bash
   rails credentials:edit
   # Add your secrets following config/credentials.yml.example
   ```

4. **Prepare database:**
   ```bash
   bin/rails db:prepare
   ```

5. **Start the server:**
   ```bash
   bin/dev
   ```

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

#### Error Tracking (Sentry)
- `SENTRY_DSN` - Sentry Data Source Name for backend error tracking
  - Get this from your [Sentry project settings](https://sentry.io)
  - Only active in production environment
  - Required for backend error tracking
- `VITE_SENTRY_DSN` - Sentry DSN for frontend error tracking
  - Same DSN as backend, but exposed to frontend via Vite
  - Only active in production builds (`npm run build`)
  - Required for frontend error tracking
- `SENTRY_TRACES_SAMPLE_RATE` - Sample rate for performance monitoring (default: 0.1)
- `VITE_SENTRY_TRACES_SAMPLE_RATE` - Frontend sample rate for performance monitoring (default: 0.1)

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
     secret_key: "sk_test_your_secret_key_here"
     publishable_key: "pk_test_your_publishable_key_here"
     webhook_secret: "whsec_your_webhook_secret_here"
   ```

**Note:** The webhook endpoint automatically handles user deletion from your platform when users delete their accounts through Clerk's user interface, eliminating the need for manual account deletion components.

### Setting Up Sentry Error Tracking

This application includes integrated error tracking with Sentry for both backend and frontend.

**Important:** Sentry is only enabled in production to avoid noise during development.

1. Create a [Sentry account](https://sentry.io) and create a new project
2. Copy your project's DSN from the project settings
3. Set the following environment variables:
   - `SENTRY_DSN` - For backend error tracking
   - `VITE_SENTRY_DSN` - For frontend error tracking (same value as above)
4. Optional: Configure sample rates:
   - `SENTRY_TRACES_SAMPLE_RATE` - Backend performance monitoring (default: 0.1)
   - `VITE_SENTRY_TRACES_SAMPLE_RATE` - Frontend performance monitoring (default: 0.1)

Sentry will automatically:
- Track errors and exceptions in both Rails and React
- Monitor performance and capture traces
- Provide session replay for frontend errors
- Tag releases with Git commit hash (useful for Heroku deployments)

#### Heroku Deployment with Sentry

For Heroku deployments, you'll need to enable the Heroku Labs runtime-dyno-metadata feature to automatically track Git commit information with your Sentry releases:

```bash
# Enable the runtime-dyno-metadata lab feature
heroku labs:enable runtime-dyno-metadata -a your-app-name

# Set your Sentry DSN environment variables
heroku config:set SENTRY_DSN="https://your-dsn@o123456.ingest.sentry.io/123456" -a your-app-name
heroku config:set VITE_SENTRY_DSN="https://your-dsn@o123456.ingest.sentry.io/123456" -a your-app-name
```

This feature provides the `HEROKU_SLUG_COMMIT` environment variable that Sentry uses to automatically tag releases with the deployed Git commit hash, making it easier to track which version of your code is running and correlate errors with specific deployments.

### Example .env file

```bash
# Clerk Configuration
VITE_CLERK_PUBLISHABLE_KEY=pk_test_your_publishable_key_here

# Sentry Error Tracking (Production only)
# SENTRY_DSN=https://your-dsn@o123456.ingest.sentry.io/123456
# VITE_SENTRY_DSN=https://your-dsn@o123456.ingest.sentry.io/123456

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
