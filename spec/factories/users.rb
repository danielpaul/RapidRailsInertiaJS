# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:clerk_id) { |n| "user_#{n}_clerk_id" }
  end
end
