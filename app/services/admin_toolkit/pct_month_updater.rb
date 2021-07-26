# frozen_string_literal: true

module AdminToolkit
  class PctMonthUpdater < BaseService
    def pct_month
      @pct_month ||= AdminToolkit::PctMonth.find(attributes[:id])
    end

    def call
      authorize! pct_month, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        ::AdminToolkit::PctMonth.transaction do
          pct_month.assign_attributes(attributes)
          propagate_changes!
          pct_month.save!
        end

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    # Increments the min of the adjacent(but with higher index) record to record's max + 1
    # eg. Say FootprintMonth(FPM) A has a min 0, max 12 and FPM B has min 13, max 18
    #    And an update is triggered for FPM A with max of 14. This method should
    #   update FPM's min to 15.
    def propagate_changes! # rubocop:disable Metrics/AbcSize
      return unless pct_month.max_changed?

      target_pct_month = AdminToolkit::PctMonth.find_by(index: pct_month.index + 1)
      return unless target_pct_month

      target_pct_month.update!(min: pct_month.max + 1)
    rescue ActiveRecord::RecordInvalid
      raise I18n.t(
        'admin_toolkit.pct_month.invalid_min',
        index: target_pct_month.index,
        new_max: pct_month.max + 1,
        old_max: target_pct_month.max
      )
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :pct_month_updated,
        owner: current_user,
        trackable: pct_month,
        parameters: attributes.except(:id)
      }
    end
  end
end
