# frozen_string_literal: true

class Org < ApplicationRecord
  validates :clerk_org_id, presence: true, uniqueness: true
end