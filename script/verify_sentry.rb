#!/usr/bin/env ruby
# frozen_string_literal: true

# Quick script to verify Sentry configuration
# Run with: ruby script/verify_sentry.rb

puts "🔍 Verifying Sentry Configuration..."
puts

# Check environment
puts "Environment: #{Rails.env}"
puts

# Check for Sentry DSN
sentry_dsn = ENV["SENTRY_DSN"]
if sentry_dsn.present?
  puts "✅ Backend SENTRY_DSN is configured"
  puts "   DSN: #{sentry_dsn[0..20]}..." if sentry_dsn.length > 20
else
  puts "❌ Backend SENTRY_DSN is not configured"
end

vite_sentry_dsn = ENV["VITE_SENTRY_DSN"]
if vite_sentry_dsn.present?
  puts "✅ Frontend VITE_SENTRY_DSN is configured"
  puts "   DSN: #{vite_sentry_dsn[0..20]}..." if vite_sentry_dsn.length > 20
else
  puts "❌ Frontend VITE_SENTRY_DSN is not configured"
end

puts

# Check if Sentry should be active
if Rails.env.production? && sentry_dsn.present?
  puts "✅ Sentry should be ACTIVE (production + DSN present)"
  
  # Check if Sentry is actually initialized
  begin
    require 'sentry-ruby'
    if Sentry.configuration.dsn.present?
      puts "✅ Sentry is initialized and configured"
      puts "   Environment: #{Sentry.configuration.environment}"
      puts "   Release: #{Sentry.configuration.release}"
    else
      puts "❌ Sentry is not properly initialized"
    end
  rescue LoadError
    puts "❌ Sentry gem not loaded"
  end
else
  puts "ℹ️  Sentry should be INACTIVE (#{Rails.env.production? ? 'DSN missing' : 'not production'})"
end

puts

# Heroku-specific checks
if ENV["HEROKU_SLUG_COMMIT"].present?
  puts "✅ Heroku deployment detected"
  puts "   Commit: #{ENV['HEROKU_SLUG_COMMIT']}"
else
  puts "ℹ️  Not a Heroku deployment (or Dyno Metadata not enabled)"
end

puts
puts "🚀 Configuration check complete!"