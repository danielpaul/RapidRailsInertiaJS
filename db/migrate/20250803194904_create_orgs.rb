# frozen_string_literal: true

class CreateOrgs < ActiveRecord::Migration[8.0]
  def change
    create_table :orgs do |t|
      t.string :clerk_org_id, null: false
      t.timestamps
    end
    
    add_index :orgs, :clerk_org_id, unique: true
  end
end