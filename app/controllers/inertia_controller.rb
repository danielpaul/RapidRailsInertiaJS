# frozen_string_literal: true

class InertiaController < ApplicationController
  before_action :authenticate_user!
  
  inertia_config default_render: true
  inertia_share flash: -> { flash.to_hash },
      auth: {
        user: -> { 
          return nil unless current_user
          {
            id: current_user.hashid,
            name: current_user.name,
            email: current_user.email
          }
        }
      }

  private

  def inertia_errors(model, full_messages: true)
    {
      errors: model.errors.to_hash(full_messages).transform_values(&:to_sentence)
    }
  end
end
