# frozen_string_literal: true

module Accessors
  module Activity
    extend ActiveSupport::Concern

    included do
      store :log_data, accessors: %i[recipient_email owner_email parameters], coder: JSON

      store :parameters, accessors: %i[
        active
        role
        previous_role
        name
        zip
        label_list
        standard
        max
        min
        investor_id
      ], coder: JSON
    end

    def status_text
      active ? I18n.t('activities.activated') : I18n.t('activities.deactivated')
    end
  end
end
