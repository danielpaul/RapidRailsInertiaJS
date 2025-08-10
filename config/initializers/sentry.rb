# frozen_string_literal: true

# Only initialize Sentry in production environment to avoid noise in development
if Rails.env.production? && ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Set tracing sample rate based on environment variable or default to 0.1 (10%)
    config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", 0.1).to_f

    # Filter out some common uninformative errors
    config.excluded_exceptions += [
      "ActionController::RoutingError",
      "ActionController::InvalidAuthenticityToken",
      "ActionController::BadRequest",
      "ActionDispatch::Http::MimeNegotiation::InvalidType"
    ]

    # Set release version if available (useful for Heroku deployments)
    config.release = ENV["HEROKU_SLUG_COMMIT"] || ENV["GIT_REV"] || "unknown"

    # Set environment
    config.environment = Rails.env
  end
end
