# Inertia Rails Starter Kit

A modern full-stack starter application with Rails backend and React frontend using Inertia.js based on the [Laravel Starter Kit](https://github.com/laravel/react-starter-kit) and [Inertia Rails Starter Kit](https://github.com/inertia-rails/react-starter-kit).

## Features

- [Inertia Rails](https://inertia-rails.dev) & [Vite Rails](https://vite-ruby.netlify.app) setup
- [React](https://react.dev) frontend with TypeScript & [shadcn/ui](https://ui.shadcn.com) component library
- [Clerk](https://clerk.com) User authentication system
- [Solid Queue](https://github.com/basecamp/solid_queue) for background job processing with in-process execution in development
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

## Background Jobs with Solid Queue

This starter kit includes [Solid Queue](https://github.com/basecamp/solid_queue) for reliable, database-backed background job processing. The setup is streamlined for development with in-process job execution.

### Quick Start

1. **Setup**: After running `bin/setup`, solid_queue tables are automatically created
2. **Development (In-Process Jobs)**: Start the server with `bin/dev` - jobs run within the same process as your web server for simplicity
3. **Production**: Jobs automatically run in separate processes using the database-backed queue

### Usage Example

```ruby
# Enqueue a background job
WelcomeEmailJob.perform_later("user@example.com", "John Doe")

# Or perform immediately
WelcomeEmailJob.perform_now("user@example.com", "John Doe")
```

### Configuration Options

**Development Environment:**
- Jobs run in-process with the web server when using `bin/dev`
- Set `SOLID_QUEUE_IN_PUMA=1` in your environment for in-process execution
- Verbose job logging is enabled for development visibility

**Production Environment:**
- Jobs run in dedicated worker processes
- Use `bin/jobs` to start worker processes separately
- Configured to use the same database connection as your main app

### Setup Verification

Run the setup script to verify your Solid Queue configuration:

```bash
bin/setup-solid-queue
```

### Troubleshooting

**Database Connection Issues:**
- Ensure PostgreSQL is running: `sudo service postgresql start`
- Create database if needed: `bin/rails db:create`
- Run setup: `bin/rails db:setup`

**Docker/Production:**
- Set `DATABASE_USERNAME` and `DATABASE_PASSWORD` environment variables
- Ensure database user has CREATE and CONNECT privileges

**Job Processing:**
- For development: Use `bin/dev` for in-process job execution
- For separate workers: Use `bin/jobs` in a separate terminal
- Monitor jobs: Check `SolidQueue::Job.count` in Rails console

### Job Processing Options

- **Development (Recommended)**: Use `bin/dev` - enables `SOLID_QUEUE_IN_PUMA=1` for in-process job execution
- **Development (Alternative)**: Use `bin/rails server` + `bin/jobs` in separate terminals
- **Production**: Jobs are processed by separate worker processes automatically

### Configuration

- Development: Jobs run in-process with your web server (via Puma plugin)
- Production: Uses separate database-backed queue processes
- All environments use PostgreSQL for queue storage

## Environment Variables

This application requires the following environment variables for proper functionality:

### Required for Development & Production

#### Clerk Authentication
- `VITE_CLERK_PUBLISHABLE_KEY` - Your Clerk publishable key (starts with `pk_test_` or `pk_live_`)
  - Get this from your [Clerk Dashboard](https://dashboard.clerk.com)
  - Add to your `.env` file for development
  - Required for frontend authentication components

#### Rails Credentials
The following secret should be added to Rails encrypted credentials using `rails credentials:edit`:
```yaml
clerk:
  api_key: "sk_test_your_secret_key_here"  # Your Clerk secret key
```

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
