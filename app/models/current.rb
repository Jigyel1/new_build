# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :current_user, :time_zone
end
