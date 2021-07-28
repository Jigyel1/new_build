# frozen_string_literal: true

module LogidzeWrapper
  def with_tracking(activity_id, transaction: false)
    Logidze.with_meta({ activity_id: activity_id }, transactional: false) do
      return unless block_given?

      transaction ? ActiveRecord::Base.transaction { yield } : yield
    end
  end
end
