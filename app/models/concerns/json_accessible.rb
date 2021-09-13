# frozen_string_literal: true

module JsonAccessible
  extend ActiveSupport::Concern

  F = %w[
    name
    kam_email
    zip
    labelList
    standard
    provider
    max
    min
    project_type
    min_cost
    max_cost
    status
    investor_id
  ].freeze

  %w[recipient_email owner_email parameters role previous_role active].each do |method|
    define_method method do
      log_data[method]
    end
  end

  F.each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  def status_text
    active ? I18n.t('activities.activated') : I18n.t('activities.deactivated')
  end
end
