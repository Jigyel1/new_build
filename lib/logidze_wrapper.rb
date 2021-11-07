# frozen_string_literal: true

module LogidzeWrapper
  def with_tracking(create_activity: true, transaction: false, &block)
    activity_id = SecureRandom.uuid

    Logidze.with_meta({ activity_id: activity_id }, transactional: false) do
      if block
        transaction ? ActiveRecord::Base.transaction(&block) : yield
      end

      if create_activity
        Activities::ActivityCreator.new(
          activity_id: activity_id,
          **activity_params
        ).call
      end
    end
  end
end
