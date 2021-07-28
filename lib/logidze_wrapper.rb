# frozen_string_literal: true

module LogidzeWrapper
  def with_tracking(activity_id, transaction: false, &block)
    Logidze.with_meta({ activity_id: activity_id }, transactional: false) do
      return unless block

      transaction ? ActiveRecord::Base.transaction(&block) : yield
    end
  end
end
