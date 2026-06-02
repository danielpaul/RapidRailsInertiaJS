# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user_agent, :ip_address
end
