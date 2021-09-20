# frozen_string_literal: true

module Projects
  class StatusUpdater < BaseService
    attr_accessor :event
    delegate :project, to: :state_machine

    def call
      state_machine.transition
    end

    private

    def state_machine
      @_state_machine ||= StateMachine.new(
        current_user: current_user,
        attributes: attributes.to_h,
        event: event
      )
    end
  end
end
