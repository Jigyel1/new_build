# frozen_string_literal: true

module Projects
  class StateMachine < BaseService
    include AASM
    include Transitions::Callbacks

    attr_accessor :event
    alias user current_user

    def initialize(attributes = {})
      super
      aasm_write_state_without_persistence(project.status.to_sym)
    end

    def transition
      send(event)
    rescue AASM::InvalidTransition
      raise t('projects.event_not_allowed')
    end

    def states
      return { archived: true } if archived?

      states = aasm.states.map(&:name)
      # If the PCT cost for the project is not set, then assume that the project doesn't qualify as a `Prio_` project.
      states.delete(:technical_analysis_completed) if begin
                                                        prio_one?
                                                      rescue NoMethodError
                                                        false
                                                      end

      states = states.reject { |state| state == :archived }
      current = states.index(aasm.current_state)

      states.each_with_index.map { |state, index| [state, index <= current] }.to_h
    end

    def project
      @project ||= Project.find(attributes[:id])
    end

    aasm whiny_transitions: true, column: :status, enum: true do
      state :open, initial: true
      state :technical_analysis, :technical_analysis_completed, :ready_for_offer, :archived

      before_all_events :before_transition_callback
      after_all_transitions :update_project_state
      after_all_events :after_transition_callback, :reset_draft_version

      event :technical_analysis, if: :to_technical_analysis? do
        transitions from: :open, to: :technical_analysis
      end

      event :technical_analysis_completed, if: :post_technical_analysis? do
        transitions from: :technical_analysis, to: :technical_analysis_completed, unless: :prio_one?
        transitions from: :technical_analysis, to: :ready_for_offer, if: :prio_one?
      end

      event :offer_ready do
        transitions from: :technical_analysis_completed, to: :technical_analysis, if: :back_to_technical_analysis?
        transitions from: :technical_analysis_completed, to: :ready_for_offer, if: :to_offer?
      end

      event :archive, if: :to_archived? do
        transitions from: :technical_analysis_completed, to: :archived
      end
    end

    private

    def back_to_technical_analysis?
      # revert status to technical analysis based on a variable sent from FE.
      false
    end

    def to_offer?
      authorize! project, to: :to_offer?, with: ProjectPolicy

      verdict = attributes.delete(:verdict)
      project.verdicts[aasm.to_state] = verdict if verdict.present?

      true
    end

    def update_project_state
      project.update!(status: aasm.to_state)
    end

    def reset_draft_version
      project.update_column(:draft_version, {})
    end

    def after_transition_callback
      callback = "after_#{aasm.current_event}"
      send(callback) if respond_to?(callback)
    end

    def before_transition_callback
      callback = "before_#{aasm.current_event}"
      send(callback) if respond_to?(callback)
    end

    def to_technical_analysis?
      authorize! project, to: :to_technical_analysis?, with: ProjectPolicy
    end

    def post_technical_analysis?
      authorize! project, to: :to_technical_analysis_completed?, with: ProjectPolicy

      # Project does not accept nested attribute for PCT Cost. So extract and remove
      # the necessary attributes before assigning those to the project.
      pct_cost = OpenStruct.new(attributes.delete(:pct_cost_attributes))

      verdict = attributes.delete(:verdict)
      project.verdicts[aasm.to_state] = verdict if verdict.present?

      project.assign_attributes(attributes)

      Transitions::TechnicalAnalysisCompletionGuard.new(
        project: project,
        project_connection_cost: pct_cost.project_connection_cost
      ).call

      true
    end

    def to_archived?
      authorize! project, to: :to_archived?, with: ProjectPolicy

      verdict = attributes.delete(:verdict)
      project.verdicts[aasm.to_state] = verdict if verdict.present?

      true
    end

    def project_priority
      @_project_priority ||= begin
                               months = project.pct_cost.payback_period
                               cost = project.pct_cost.project_cost

                               AdminToolkit::PctValue
                                 .joins(:pct_cost, :pct_month)
                                 .where('admin_toolkit_pct_months.min <= :value AND admin_toolkit_pct_months.max >= :value', value: months)
                                 .find_by('admin_toolkit_pct_costs.min <= :value AND admin_toolkit_pct_costs.max >= :value', value: cost)
                             end
    end

    def prio_one?
      project_priority.try(:prio_one?)
    end
  end
end
