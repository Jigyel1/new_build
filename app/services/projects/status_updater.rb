module Projects
  class StatusUpdater < BaseService
    include AASM
    alias :user :current_user

    def initialize(attributes = {})
      super
      aasm_write_state_without_persistence(project.status.to_sym)
    end

    def call
      send(attributes[:status])
    rescue AASM::InvalidTransition
      raise t('projects.invalid_transition')
    end

    aasm whiny_transitions: true, column: :status, enum: true do
      state :open, initial: true
      state :technical_analysis, :technical_analysis_completed, :offer_ready

      after_all_transitions :update_project_state

      event :technical_analysis, if: :to_technical_analysis? do
        transitions from: :open, to: :technical_analysis
      end

      event :technical_analysis_complete do
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
      %i[super_user admin management team_expert presales manager_nbo_kam manager_presales].any? do |role|
        user.send("#{role}?")
      end
    end

    def project
      @project ||= Project.find(attributes[:id])
    end

    # Callbacks
    # def after_technical_analysis
    #   log activity
    #   notify users
    # end
  end
end