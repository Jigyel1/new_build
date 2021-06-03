# frozen_string_literal: true

module TimeZone
  extend ActiveSupport::Concern

  included do
    around_action :use_time_zone
  end

  private

  def use_time_zone(&block)
    Time.use_zone(
      ActiveSupport::TimeZone[request.headers.fetch('X-TIME-ZONE', '')] || Time.zone,
      &block
    )
  end
end
