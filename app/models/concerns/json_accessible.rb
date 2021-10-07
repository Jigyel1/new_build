# frozen_string_literal: true

module JsonAccessible
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
      previous_status
      investor_id
      status
      role_type
      filename
      project_name
      title
      entry_type
    ], coder: JSON
  end

  def status_text
    active ? I18n.t('activities.activated') : I18n.t('activities.deactivated')
  end
end
