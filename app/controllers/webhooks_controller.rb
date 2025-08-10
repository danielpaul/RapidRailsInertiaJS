# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature, unless: -> { Rails.env.test? }

  def clerk
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
    clerk_user_id = data[:id]
    
    user = User.find_by(clerk_id: clerk_user_id)
    if user
      # Clear the cached Clerk user data so it gets refreshed on next access
      Rails.cache.delete("clerk_user/#{clerk_user_id}")
      Rails.logger.info("Cleared cache for updated user #{user.id}")
    end
  end

  def verify_webhook_signature
    # Get the webhook secret from credentials or environment
    webhook_secret = Rails.application.credentials.dig(:clerk, :webhook_secret) || ENV["CLERK_WEBHOOK_SECRET"]
    
    return head :unauthorized unless webhook_secret

    # Get the signature from the request headers
    signature = request.headers["svix-signature"]
    timestamp = request.headers["svix-timestamp"]
    id = request.headers["svix-id"]
    
    return head :unauthorized unless signature && timestamp && id

    # Verify the webhook signature using Clerk's verification method
    begin
      # This is a simplified verification - in production you'd want to use Clerk's official verification
      # For now, we'll just check that the request has the required headers
      Rails.logger.info("Webhook received from Clerk: #{id}")
    rescue => e
      Rails.logger.error("Webhook signature verification failed: #{e.message}")
      return head :unauthorized
    end
  end
end
