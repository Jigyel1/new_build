# frozen_string_literal: true

module JsonAccessible
  extend ActiveSupport::Concern

  # TODO: OR change this to store :log_data, accessors: %i[recipient_email owner_email...], coder: JSON
  %w[recipient_email owner_email parameters].each do |method|
    define_method method do
      log_data[method]
    end
  end

  %w[role previous_role active investor_id].each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  def status_text
    active ? I18n.t('activities.activated') : I18n.t('activities.deactivated')
  end
end
