module Projects
  class StatusUpdater < BaseService
    include AASM
    include Transitions::Callbacks
    alias :user :current_user
    attr_accessor :event

    def initialize(attributes = {})
      super
      aasm_write_state_without_persistence(project.status.to_sym)
    end

    def call
      send(event)
    rescue AASM::InvalidTransition
      raise t('projects.event_not_allowed')
    end

    def project
      @project ||= Project.find(attributes[:id])
    end

    aasm whiny_transitions: true, column: :status, enum: true do
      state :open, initial: true
      state :technical_analysis, :technical_analysis_completed, :offer_ready

      after_all_transitions :update_project_state

      event :technical_analysis, if: :to_technical_analysis? do
        transitions from: :open, to: :technical_analysis
      end

      event :technical_analysis_completed, if: :to_technical_analysis_completed? do
        transitions from: :technical_analysis, to: :technical_analysis_completed
      end

      event :offer_ready do
        transitions from: :technical_analysis_completed, to: :ready_for_offer
      end
    end

    private

    def update_project_state
      project.update!(status: aasm.to_state)
    end

    def to_technical_analysis?
      authorize! project, to: :to_technical_analysis?, with: ProjectPolicy
    end

    def to_technical_analysis_completed?
      authorize! project, to: :to_technical_analysis_completed?, with: ProjectPolicy

      project.assign_attributes(attributes)
      Transitions::TechnicalAnalysisCompletionValidator.new(project: project).call

      true
    end
  end
end
