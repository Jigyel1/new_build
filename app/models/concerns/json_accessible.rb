# frozen_string_literal: true

module JsonAccessible
  extend ActiveSupport::Concern

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

  %w[name].each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  %w[zip].each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  %w[max].each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  %w[labelList].each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  %w[standard].each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  %w[provider max min project_type].each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  %w[name kam_email].each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  def status_text
    active ? I18n.t('activities.activated') : I18n.t('activities.deactivated')
  end
end
