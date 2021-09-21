# frozen_string_literal: true

module JsonAccessible
  extend ActiveSupport::Concern

  %w[recipient_email owner_email parameters].each do |method|
    define_method method do
      log_data[method]
    end
  end

  PARAMETERS = %w[
    role
    previous_role
    active
    name
    zip
    labelList
    standard
    max
    min
    investor_id
  ].freeze

  PARAMETERS.each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  def status_text
    active ? I18n.t('activities.activated') : I18n.t('activities.deactivated')
  end
end
