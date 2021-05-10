# frozen_string_literal: true

module LogidzeWrapper
  def with_tracking(activity_id)
    Logidze.with_meta({ activity_id: activity_id }, transactional: false) do
      yield if block_given?
    end
  end
end
