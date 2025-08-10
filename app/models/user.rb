# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  clerk_id   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_clerk_id  (clerk_id) UNIQUE
#
class User < ApplicationRecord
  include Hashid::Rails
  
  validates :clerk_id, presence: true, uniqueness: true

  def clerk_user
    @clerk_user ||= fetch_clerk_user
  end

  def name
    return "Test User" if Rails.env.test?
    return "User" unless clerk_user
    [clerk_user.first_name, clerk_user.last_name].compact.join(" ")
  end

  def email
    return "test@example.com" if Rails.env.test?
    return nil unless clerk_user
    
    clerk_user.email_addresses&.find { |email| email.id == clerk_user.primary_email_address_id }&.email_address
  end

  private

  def fetch_clerk_user
    return nil if Rails.env.test? # Skip API calls in test
    
    # Cache for longer period since we'll clear cache via webhook when Clerk user is updated
    Rails.cache.fetch("clerk_user/#{clerk_id}", expires_in: 24.hours) do
      Clerk::SDK.new.users.get_user(clerk_id)
    end
  rescue Clerk::Errors::Base => e
    Rails.logger.error("Failed to fetch Clerk user #{clerk_id}: #{e.message}")
    nil
  rescue => e
    Rails.logger.error("Unexpected error fetching Clerk user #{clerk_id}: #{e.message}")
    nil
  end
end
