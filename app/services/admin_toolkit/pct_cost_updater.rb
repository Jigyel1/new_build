# frozen_string_literal: true

module AdminToolkit
  class PctCostUpdater < BaseService
    def pct_cost
      @pct_cost ||= AdminToolkit::PctCost.find(attributes[:id])
    end

    def call
      authorize! pct_cost, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        ::AdminToolkit::PctCost.transaction do
          pct_cost.assign_attributes(attributes)
          propagate_changes!
          pct_cost.save!
        end

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    # Increments the min of the adjacent(but with higher index) record to record's max + 1
    # eg. Say FootprintCost(FPC) A has a min 10, max 1000 and FPC B has min 1001, max 3000
    #    And an update is triggered for FPC A with max of 1501. This method should
    #   update FPC's min to 1502.
    def propagate_changes! # rubocop:disable Metrics/AbcSize
      return unless pct_cost.max_changed?

      target_pct_cost = AdminToolkit::PctCost.find_by(index: pct_cost.index + 1)
      return unless target_pct_cost

      target_pct_cost.update!(min: pct_cost.max + 1)
    rescue ActiveRecord::RecordInvalid
      raise I18n.t(
        'admin_toolkit.pct_cost.invalid_min',
        index: target_pct_cost.index,
        new_max: pct_cost.max + 1,
        old_max: target_pct_cost.max
      )
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :pct_cost_updated,
        owner: current_user,
        trackable: pct_cost,
        parameters: attributes.except(:id)
      }
    end
  end
end
