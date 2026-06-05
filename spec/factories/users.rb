# frozen_string_literal: true

# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  clerk_id   :string           not null
#
# Indexes
#
#  index_users_on_clerk_id  (clerk_id) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:clerk_id) { |n| "user_#{n}_clerk_id" }
  end
end
