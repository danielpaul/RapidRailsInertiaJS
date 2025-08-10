# frozen_string_literal: true

# Solid Queue configuration for streamlined setup
Rails.application.configure do
  # Configure solid_queue database connections for all environments
  if respond_to?(:solid_queue)
    config.solid_queue.connects_to = {database: {writing: :queue}}
  end
end