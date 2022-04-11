# frozen_string_literal: true

module Projects
  class StateMachine < BaseService
    include AASM
    include Transitions::Callbacks
    include Transitions::Helper

    delegate :status, :marketing_only?, to: :project

    attr_accessor :event
    alias user current_user

    def initialize(attributes = {})
      super
      aasm_write_state_without_persistence(status.to_sym)
    end

    def transition
      send(event)
    rescue AASM::InvalidTransition
      raise t('projects.transition.event_not_allowed')
    end

    def states
      return { archived: true } if archived?

      states = aasm.states.map(&:name)

      states = states.except(*irrelevant_states)
      states = states.reject { |state| state == :archived }
      current = states.index(aasm.current_state)

      states.each_with_index.to_h { |state, index| [state, index <= current] }
    end

    def project
      @project ||= Project.find(attributes[:id])
    end

    aasm whiny_transitions: true, column: :status, enum: true do
      state :open, initial: true
      state :technical_analysis, :technical_analysis_completed, :ready_for_offer, :commercialization, :archived,
            :offer_confirmation

      after_all_transitions :update_project_state, :record_activity
      after_all_events :after_transition_callback, :reset_draft_version

      event :revert, if: :revert? do
        transitions from: :technical_analysis, to: :open
        transitions from: :technical_analysis_completed, to: :technical_analysis
        transitions from: :ready_for_offer, to: :technical_analysis, if: :prio_one?
        transitions from: :ready_for_offer, to: :technical_analysis_completed, unless: :prio_one?
        transitions from: :offer_confirmation, to: :ready_for_offer, after: :remove_status
        transitions from: :commercialization, to: :technical_analysis, if: :marketing_only?
      end

      event :technical_analysis, if: :authorized?, after: :assign_incharge do
        transitions from: :open, to: :technical_analysis
      end

      event :technical_analysis_completed, if: %i[authorized? before_technical_analysis_completed] do
        transitions from: :technical_analysis, to: :technical_analysis_completed, unless: %i[marketing_only? prio_one?]
        transitions from: :technical_analysis, to: :ready_for_offer, if: :prio_one?, unless: :marketing_only?
        transitions from: :technical_analysis, to: :commercialization, if: :marketing_only?
      end

      event :offer_ready, if: :authorized?, after: :extract_verdict do
        transitions from: :technical_analysis_completed, to: :ready_for_offer
      end

      event :offer_confirmation, if: :authorized?, after: :set_default_status do
        transitions from: :ready_for_offer, to: :offer_confirmation
      end

      event :archive, if: :authorized?, after: :extract_verdict do
        transitions from: :open, to: :archived
        transitions from: :technical_analysis, to: :archived
        transitions from: :technical_analysis_completed, to: :archived
        transitions from: :ready_for_offer, to: :archived
      end

      event :unarchive, if: :unarchive? do
        transitions from: :archived, to: :open
        transitions from: :archived, to: :technical_analysis
        transitions from: :archived, to: :technical_analysis_completed
        transitions from: :archived, to: :ready_for_offer
      end
    end
  end
end
