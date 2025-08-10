#!/bin/bash

# Demo script to show Sentry configuration in action
# This script demonstrates how to set up and verify Sentry integration

echo "🎯 Sentry Error Tracking Demo for RapidRailsInertiaJS"
echo "=================================================="
echo

echo "📋 Setup Instructions:"
echo "1. Create a Sentry account at https://sentry.io"
echo "2. Create a new project and copy the DSN"
echo "3. Set environment variables (see .heroku-sentry-config.example)"
echo

echo "🔧 Environment Variables to Set:"
echo "SENTRY_DSN=https://your-dsn@o123456.ingest.sentry.io/123456"
echo "VITE_SENTRY_DSN=https://your-dsn@o123456.ingest.sentry.io/123456"
echo

echo "☁️  For Heroku Deployment:"
echo "heroku config:set SENTRY_DSN=\"https://your-dsn@o123456.ingest.sentry.io/123456\""
echo "heroku config:set VITE_SENTRY_DSN=\"https://your-dsn@o123456.ingest.sentry.io/123456\""
echo

echo "🧪 Testing Routes (Development Only):"
echo "http://localhost:3000/sentry_test/backend_error  - Test Rails error tracking"
echo "http://localhost:3000/sentry_test/frontend_error - Test React error tracking"
echo "http://localhost:3000/sentry_test/performance   - Test performance monitoring"
echo

echo "✅ Features Included:"
echo "• Backend error tracking with Rails (production only)"
echo "• Frontend error tracking with React (production only)"
echo "• Performance monitoring and tracing"
echo "• Session replay for frontend errors"
echo "• Automatic release tracking with Git commits"
echo "• Heroku deployment support"
echo

echo "🔍 Verify Configuration:"
echo "ruby script/verify_sentry.rb"
echo

echo "📖 Documentation updated in README.md"
echo "🎉 Sentry integration complete!"