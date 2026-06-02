# frozen_string_literal: true

# Rate limiting via Rack::Attack. The middleware is inserted automatically by
# the gem's railtie; this file only configures the rules.
# See https://github.com/rack/rack-attack
class Rack::Attack
  # Use the Rails cache (solid_cache in production) to track request counts.
  Rack::Attack.cache.store = Rails.cache

  # Throttle Clerk webhook deliveries per IP. Signature verification already
  # rejects forged payloads; this caps the volume a single source can send.
  throttle("webhooks/clerk/ip", limit: 30, period: 1.minute) do |request|
    request.ip if request.post? && request.path == "/webhooks/clerk"
  end

  # General safety net for all other dynamic requests (assets excluded).
  throttle("req/ip", limit: 300, period: 5.minutes) do |request|
    request.ip unless request.path.start_with?("/assets", "/vite")
  end

  # Return 429 with a small retry hint when throttled.
  self.throttled_responder = lambda do |request|
    retry_after = (request.env["rack.attack.match_data"] || {})[:period]
    [429, {"Content-Type" => "text/plain", "Retry-After" => retry_after.to_s}, ["Too many requests\n"]]
  end
end
