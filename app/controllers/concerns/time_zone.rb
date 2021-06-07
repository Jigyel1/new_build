# frozen_string_literal: true

module TimeZone
  extend ActiveSupport::Concern

  included do
    around_action :use_time_zone
  end

  private

  def use_time_zone(&block)
    Time.use_zone(time_zone, &block)
  end

  def time_zone
    ActiveSupport::TimeZone[request.headers.fetch('X-Time-Zone', '')] || Time.zone
  end
end
