# frozen_string_literal: true

class InertiaController < ApplicationController
  inertia_config default_render: true
  inertia_share flash: -> { flash.to_hash },
      auth: {
        user: -> { 
          return nil unless current_user
          {
            id: current_user.id,
            clerk_id: current_user.clerk_id,
            name: current_user.name,
            created_at: current_user.created_at,
            updated_at: current_user.updated_at
          }
        },
        session: -> { Current.session&.as_json(only: %i[id]) }
      }

  private

  def inertia_errors(model, full_messages: true)
    {
      errors: model.errors.to_hash(full_messages).transform_values(&:to_sentence)
    }
  end
end
