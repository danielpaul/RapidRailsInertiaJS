# frozen_string_literal: true

class TransformUsersForClerk < ActiveRecord::Migration[8.0]
  def change
    # Remove authentication-zero fields and add clerk_id
    remove_column :users, :name, :string
    remove_column :users, :email, :string
    remove_column :users, :password_digest, :string
    remove_column :users, :verified, :boolean
    
    # Add clerk_id field
    add_column :users, :clerk_id, :string, null: false
    add_index :users, :clerk_id, unique: true
  end
end
