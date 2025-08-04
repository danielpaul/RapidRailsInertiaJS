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
  validates :clerk_id, presence: true, uniqueness: true

  has_many :sessions, dependent: :destroy

  # Hashids for obfuscating user IDs in frontend
  def self.hashids
    @hashids ||= Hashids.new("user-salt", 8)
  end

  def to_param
    self.class.hashids.encode(id)
  end

  def self.find_by_hashid(hashid)
    decoded_ids = hashids.decode(hashid)
    return nil if decoded_ids.empty?
    find_by(id: decoded_ids.first)
  end

  def hashid
    self.class.hashids.encode(id)
  end

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
    clerk_user.email_addresses&.find(&:primary?)&.email_address
  end

  private

  def fetch_clerk_user
    return nil if Rails.env.test? # Skip API calls in test
    
    Rails.cache.fetch("clerk_user/#{clerk_id}", expires_in: 1.hour) do
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
