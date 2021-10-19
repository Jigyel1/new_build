# frozen_string_literal: true

module Projects
  class StateMachine < BaseService
    include AASM
    include Transitions::Callbacks
    include Transitions::Helper

    attr_accessor :event
    alias user current_user

    def initialize(attributes = {})
      super
      aasm_write_state_without_persistence(project.status.to_sym)
    end

    def transition
      send(event)
    rescue AASM::InvalidTransition
      raise t('projects.transition.event_not_allowed')
    end

    def states
      return { archived: true } if archived?

      states = aasm.states.map(&:name)
      # If the PCT cost for the project is not set, then assume that the project doesn't qualify as a `Prio_1` project.
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

      after_all_transitions :update_project_state, :record_activity
      after_all_events :after_transition_callback, :reset_draft_version

      event :revert, if: :authorized? do
        transitions from: :technical_analysis, to: :open
        transitions from: :technical_analysis_completed, to: :technical_analysis
        transitions from: :ready_for_offer, to: :technical_analysis, if: :prio_one?
        transitions from: :ready_for_offer, to: :technical_analysis_completed, unless: :prio_one?
      end

      event :technical_analysis, if: :authorized? do
        transitions from: :open, to: :technical_analysis
      end

      event :technical_analysis_completed, if: %i[authorized? before_technical_analysis_completed] do
        transitions from: :technical_analysis, to: :technical_analysis_completed, unless: :prio_one?
        transitions from: :technical_analysis, to: :ready_for_offer, if: :prio_one?
      end

      event :offer_ready, if: :authorized?, after: :extract_verdict do
        transitions from: :technical_analysis_completed, to: :ready_for_offer
      end

      event :archive, if: :authorized?, after: :extract_verdict do
        transitions from: :open, to: :archived
        transitions from: :technical_analysis, to: :archived
        transitions from: :technical_analysis_completed, to: :archived
        transitions from: :ready_for_offer, to: :archived
      end

      event :unarchive, if: %i[authorized? unarchive?], after: :extract_verdict do
        transitions from: :archived, to: :open
        transitions from: :archived, to: :technical_analysis
        transitions from: :archived, to: :technical_analysis_completed
        transitions from: :archived, to: :ready_for_offer
      end
    end

    def unarchive?
      project.previous_status.to_sym == aasm.to_state
    end
  end
end
