# frozen_string_literal: true

module Accessors
  module Activity
    extend ActiveSupport::Concern

    USER_ACCESSORS = %i[active role previous_role name].freeze
    ADMIN_TOOLKIT_ACCESSORS = %i[name zip label_list standard max min investor_id].freeze

    PROJECT_ACCESSORS = %i[
      name previous_status incharge_email label_list status
      address_book_type filename project_name title entry_type type
    ].freeze

    included do
      store :log_data, accessors: %i[recipient_email owner_email parameters], coder: JSON

      store(
        :parameters,
        accessors: [*USER_ACCESSORS, *ADMIN_TOOLKIT_ACCESSORS, *PROJECT_ACCESSORS],
        coder: JSON
      )
    end

    private

    def status_text
      active ? I18n.t('activities.activated') : I18n.t('activities.deactivated')
    end
  end
end
