# frozen_string_literal: true

module Projects
  module UnarchiveSpecHelper
    def transitions(project, states)
      states.each { |state| project.update!(status: state) }
    end
  end
end
