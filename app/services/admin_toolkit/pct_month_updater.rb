# frozen_string_literal: true

module AdminToolkit
  class PctMonthUpdater < BaseService
    def pct_month
      @pct_month ||= AdminToolkit::PctMonth.find(attributes[:id])
    end

    def call
      authorize! pct_month, to: :update?, with: AdminToolkitPolicy

      with_tracking(transaction: true) do
        pct_month.assign_attributes(attributes)
        propagate_changes!
        pct_month.save!
      end
    end

    private

    # We take the min of the adjacent(but with higher index) record to record's max
    # eg. Say FootprintMonth(FPM) A has a min 0, max 12 and FPM B has min 12, max 18
    #    And an update is triggered for FPM A with max of 15. This method should
    #   update FPM's min to 15.
    def propagate_changes!
      return unless pct_month.max_changed?

      target_pct_month = AdminToolkit::PctMonth.find_by(index: pct_month.index + 1)
      return unless target_pct_month

      target_pct_month.update!(min: pct_month.max)
    end

    def activity_params
      {
        action: :pct_month_updated,
        owner: current_user,
        trackable: pct_month,
        parameters: attributes.except(:id)
      }
    end
  end
end
