# frozen_string_literal: true

# A preferred way to implement this would have been through a use of
# `store` accessor from ActiveRecord. This however was affecting the
# query(returning unexpected results).
# TODO: Try this again and see if it works before raising a PR.
module JsonAccessible
  extend ActiveSupport::Concern

  %w[recipient_email owner_email].each do |method|
    define_method method do
      log_data[method]
    end
  end

  %w[role previous_role active].each do |method|
    define_method method do
      log_data.dig('parameters', method)
    end
  end

  def status_text
    active ? I18n.t('activities.activated') : I18n.t('activities.deactivated')
  end
end
