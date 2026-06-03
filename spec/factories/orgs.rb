# frozen_string_literal: true

FactoryBot.define do
  factory :org do
    sequence(:clerk_org_id) { |n| "org_#{n}_clerk_org_id" }
  end
end
