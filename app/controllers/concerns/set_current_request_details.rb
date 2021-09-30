# frozen_string_literal: true

module SetCurrentRequestDetails
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.current_user = current_user
      Current.time_zone = time_zone
    end
  end
end
