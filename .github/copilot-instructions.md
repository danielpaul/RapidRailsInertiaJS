# RapidRailsInertiaJS Development Instructions

**ALWAYS follow these instructions first** and only fallback to additional search and context gathering if the information here is incomplete or found to be in error.

## Overview

RapidRailsInertiaJS is a modern full-stack starter application combining Rails 8.0.2 backend with React frontend using Inertia.js. The tech stack includes:

- **Backend**: Rails 8.0.2 with PostgreSQL database
- **Frontend**: React with TypeScript, Vite, and shadcn/ui components
- **Authentication**: Clerk for user management
- **Testing**: RSpec for backend, no frontend tests
- **Process Management**: Supports overmind/hivemind (preferred) or foreman
- **Deployment**: Kamal for containerized deployment

## Critical Setup Requirements

### System Dependencies
Install these dependencies before proceeding:
```bash
sudo apt-get update && sudo apt-get install -y \
  build-essential \
  libpq-dev \
  postgresql \
  postgresql-contrib \
  ruby-bundler
```

### Ruby Version Requirements
- **Required**: Ruby 3.2.3+ (project specifies 3.4.4 in .ruby-version but 3.2.3 works)
- **System Ruby Issue**: Default system bundler has permission issues
- **Solution**: Use local bundler configuration (see setup steps below)

### Node.js Requirements
- **Required**: Node.js 20+ (CI uses Node 22)
- **Current validated**: v20.19.4 works correctly

## Bootstrap and Build Process

### 1. Install Dependencies
**NEVER CANCEL BUILDS** - Allow full completion. Set timeout to 120+ seconds.

```bash
# Configure bundler for local installation (CRITICAL for avoiding permission errors)
bundle config set --local path 'vendor/bundle'
bundle config set --local without 'production'

# Install Ruby dependencies (takes ~1 minute)
time bundle install  # NEVER CANCEL: Takes 60-90 seconds

# Install Node.js dependencies (takes ~55 seconds)
time npm install     # NEVER CANCEL: Takes 45-60 seconds
```

**Measured Timing**: 
- Bundle install: 61 seconds
- NPM install: 55 seconds

### 2. Database Setup
**CRITICAL**: Requires PostgreSQL running with proper credentials.

```bash
# Start PostgreSQL (if not running)
sudo service postgresql start

# Create database user (one-time setup)
sudo -u postgres createuser -s $USER
sudo -u postgres psql -c "ALTER USER $USER WITH PASSWORD 'password';"

# Set environment variables for database access
export DATABASE_USERNAME=$USER
export DATABASE_PASSWORD=password

# Prepare database (creates development and test databases)
time DATABASE_USERNAME=$USER DATABASE_PASSWORD=password bin/rails db:prepare
```

**Measured Timing**: Database preparation: ~1 second

### 3. Environment Configuration
Copy and configure environment variables:
```bash
cp .env.example .env
echo "DATABASE_PASSWORD=password" >> .env
```

**REQUIRED FOR AUTHENTICATION**: Add Clerk publishable key to `.env`:
```bash
VITE_CLERK_PUBLISHABLE_KEY=pk_test_your_actual_key_here
```

## Running the Application

### Development Servers
**Two-Process Setup**: Rails backend + Vite frontend

```bash
# Option 1: Use process manager (preferred if available)
DATABASE_USERNAME=$USER DATABASE_PASSWORD=password bin/dev

# Option 2: Manual startup (fallback when foreman not available)
# Terminal 1 - Rails server
DATABASE_USERNAME=$USER DATABASE_PASSWORD=password bin/rails server -p 3000

# Terminal 2 - Vite dev server  
bundle exec vite dev
```

**Access URLs**:
- Application: http://localhost:3000
- Vite dev server: http://localhost:3036/vite-dev/

**Process Manager Notes**:
- Prefers: overmind > hivemind > foreman
- `bin/dev` installs foreman if missing (may fail with permission issues)
- Use manual startup as reliable fallback

## Validation and Testing

### Linting and Code Quality
Run these before committing changes:

```bash
# Frontend linting (takes ~6 seconds)
npm run lint                    # ESLint check
npm run lint:fix               # Auto-fix ESLint issues

# Frontend formatting (takes ~2 seconds)  
npm run format                 # Prettier check
npm run format:fix             # Auto-fix Prettier formatting

# TypeScript checking (takes ~5 seconds)
npm run check                  # Type checking

# Ruby linting (takes ~2 seconds)
bin/rubocop                    # Ruby style check

# Security scanning (takes ~3.5 seconds)
bin/brakeman --no-pager        # Security vulnerability scan
```

**CRITICAL FOR CI**: Always run `npm run format`, `npm run lint`, and `npm run check` before committing. The CI pipeline (.github/workflows/ci.yml) will fail without these.

### Running Tests
```bash
# Run full test suite (takes ~8.5 seconds, loads in 8.3 seconds)
DATABASE_USERNAME=$USER DATABASE_PASSWORD=password bundle exec rspec

# Test count: 36 examples total
# Expected: 1 failing test in spec/config/sentry_spec.rb (known issue)
```

**NEVER CANCEL**: Test suite takes 8-9 seconds total, wait for completion.

### Building for Production
```bash
# Build frontend assets (takes ~7 seconds)
time bundle exec vite build    # NEVER CANCEL: Takes 5-8 seconds

# Note: No npm build script - use Vite directly
```

**Measured Timing**: Vite build: 7 seconds

## Manual Validation Scenarios

After making changes, always test these key workflows:

### 1. Basic Application Access
```bash
# Start servers and test
curl -s http://localhost:3000/ | head -5
# Should return HTML with "Inertia Rails Shadcn Starter" title
```

### 2. Authentication Flow (with Clerk configured)
- Navigate to http://localhost:3000
- Test sign-in/sign-up flows
- Verify dashboard access after authentication

### 3. Full Build Verification
```bash
# Run complete validation sequence
npm run format && npm run lint && npm run check
bin/rubocop && bin/brakeman --no-pager
bundle exec rspec
bundle exec vite build
```

## Key Project Structure

### Frontend (app/frontend/)
```
components/     # shadcn/ui components
entrypoints/    # Vite entry points (inertia.ts)
hooks/          # React hooks
layouts/        # Page layouts
pages/          # Inertia.js pages
routes/         # Client-side routing
types/          # TypeScript definitions
```

### Backend (Rails structure)
```
app/controllers/    # Rails controllers (Inertia-enabled)
app/models/         # ActiveRecord models
config/             # Rails configuration
db/                 # Database schemas and seeds
spec/               # RSpec tests
```

### Configuration Files
- `package.json`: Node.js dependencies and scripts
- `Gemfile`: Ruby dependencies  
- `config/database.yml`: Database configuration (PostgreSQL)
- `config/deploy.yml`: Kamal deployment configuration
- `vite.config.ts`: Vite build configuration
- `.github/workflows/ci.yml`: CI pipeline

## Common Issues and Solutions

### Database Connection Errors
**Error**: `connection to server at "::1", port 5432 failed`
**Solution**: 
1. Start PostgreSQL: `sudo service postgresql start`
2. Set credentials: `DATABASE_USERNAME=$USER DATABASE_PASSWORD=password`

### Permission Errors During Setup
**Error**: `You don't have write permissions for the /var/lib/gems/3.2.0 directory`
**Solution**: Use local bundler config (already in setup steps above)

### Bundler Version Mismatch
**Error**: `Bundler 2.4.20 is running, but your lockfile was generated with 2.6.7`
**Solution**: This warning is normal, bundler continues with compatible version

### Process Manager Installation Fails
**Error**: `gem install foreman` permission denied
**Solution**: Use manual server startup (Option 2 above)

### Frontend Build Warnings
**Warning**: "Some chunks are larger than 500 kB after minification"
**Note**: This is expected and normal for the current build

## Deployment Notes

- **Production**: Uses Kamal for containerized deployment
- **SSR Support**: Optional, disabled by default (see README.md for enabling)
- **Docker**: Dockerfile and Dockerfile-ssr available for containerization
- **CI/CD**: GitHub Actions workflow validates all builds and tests

## Environment Variables Reference

### Required for Development
```bash
DATABASE_USERNAME=$USER                           # Your system username
DATABASE_PASSWORD=password                        # Database password
VITE_CLERK_PUBLISHABLE_KEY=pk_test_...           # Clerk authentication
```

### Optional for Advanced Features  
```bash
SENTRY_DSN=https://...                           # Error tracking (production)
VITE_SENTRY_DSN=https://...                      # Frontend error tracking
FROM_EMAIL=noreply@yourdomain.com                # Email sender
HOST=yourdomain.com                              # Production host
```

## Quick Reference Commands

```bash
# Complete setup from scratch
bundle config set --local path 'vendor/bundle'
bundle install && npm install
cp .env.example .env
DATABASE_USERNAME=$USER DATABASE_PASSWORD=password bin/rails db:prepare

# Daily development
DATABASE_USERNAME=$USER DATABASE_PASSWORD=password bin/dev
# OR manual: bin/rails server + bundle exec vite dev

# Pre-commit validation  
npm run format && npm run lint && npm run check && bin/rubocop

# Test and build
bundle exec rspec
bundle exec vite build
```

**Remember**: Always wait for commands to complete. Build and test times are measured and documented above - use these for timeout expectations.