# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature, unless: -> { Rails.env.test? }

  def clerk
    return head :ok unless first_delivery?

    event_type = params[:type]

    case event_type
    when "user.deleted"
      handle_user_deleted(params[:data])
    when "user.updated"
      handle_user_updated(params[:data])
    else
      Rails.logger.info("Unhandled Clerk webhook event: #{event_type}")
    end

    head :ok
  end

  private

  # Svix retries deliveries on non-2xx responses or timeouts, so the same event
  # can arrive more than once. Use the unique `svix-id` to process each delivery
  # only once. Returns false when this delivery has already been seen.
  def first_delivery?
    svix_id = request.headers["svix-id"]
    return true if svix_id.blank?

    Rails.cache.write("webhooks/clerk/#{svix_id}", true, expires_in: 1.hour, unless_exist: true)
  end

  def handle_user_deleted(data)
    # Clerk webhook payload structure: data contains the user object
    clerk_user_id = data[:id] || data["id"]

    user = User.find_by(clerk_id: clerk_user_id)
    if user
      Rails.logger.info("Deleting user #{user.id} due to Clerk user deletion")
      user.destroy!
    else
      Rails.logger.warn("User with clerk_id #{clerk_user_id} not found for deletion")
    end
  end

  def handle_user_updated(data)
    clerk_user_id = data[:id] || data["id"]

    user = User.find_by(clerk_id: clerk_user_id)
    if user
      # Clear the cached Clerk user data so it gets refreshed on next access
      Rails.cache.delete("clerk_user/#{clerk_user_id}")
      Rails.logger.info("Cleared cache for updated user #{user.id}")
    end
  end

  # Clerk signs webhooks with Svix. Verify the payload using the documented
  # HMAC-SHA256 scheme: https://docs.svix.com/receiving/verifying-payloads/how-manual
  def verify_webhook_signature
    webhook_secret = Rails.application.credentials.dig(:clerk, :webhook_secret) || ENV["CLERK_WEBHOOK_SECRET"]
    return head :unauthorized unless webhook_secret

    svix_id = request.headers["svix-id"]
    svix_timestamp = request.headers["svix-timestamp"]
    svix_signature = request.headers["svix-signature"]
    return head :unauthorized unless svix_id && svix_timestamp && svix_signature

    valid = valid_signature?(webhook_secret, svix_id, svix_timestamp, svix_signature, request.raw_post)
    return head :unauthorized unless valid

    Rails.logger.info("Verified Clerk webhook: #{svix_id}")
  rescue ArgumentError, OpenSSL::OpenSSLError => e
    Rails.logger.error("Webhook signature verification failed: #{e.message}")
    head :unauthorized
  end

  def valid_signature?(webhook_secret, svix_id, svix_timestamp, svix_signature, payload)
    return false unless timestamp_within_tolerance?(svix_timestamp)

    # The secret is prefixed with "whsec_" and the remainder is base64 encoded.
    secret_bytes = Base64.strict_decode64(webhook_secret.delete_prefix("whsec_"))
    signed_content = "#{svix_id}.#{svix_timestamp}.#{payload}"
    expected = Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", secret_bytes, signed_content))

    # The header holds a space-separated list of "version,signature" pairs.
    svix_signature.split(" ").any? do |versioned_signature|
      _version, signature = versioned_signature.split(",", 2)
      signature && ActiveSupport::SecurityUtils.secure_compare(signature, expected)
    end
  end

  # Reject stale timestamps to guard against replay attacks (5 minute window).
  def timestamp_within_tolerance?(svix_timestamp, tolerance: 5.minutes)
    (Time.now.to_i - Integer(svix_timestamp)).abs <= tolerance.to_i
  rescue ArgumentError, TypeError
    false
  end
end
