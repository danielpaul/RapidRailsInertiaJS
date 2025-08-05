# frozen_string_literal: true

class DropSessions < ActiveRecord::Migration[8.0]
  def change
    drop_table :sessions, if_exists: true
  end
end