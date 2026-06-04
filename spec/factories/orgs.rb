# frozen_string_literal: true

# == Schema Information
#
# Table name: orgs
# Database name: primary
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  clerk_org_id :string           not null
#
# Indexes
#
#  index_orgs_on_clerk_org_id  (clerk_org_id) UNIQUE
#
FactoryBot.define do
  factory :org do
    sequence(:clerk_org_id) { |n| "org_#{n}_clerk_org_id" }
  end
end
