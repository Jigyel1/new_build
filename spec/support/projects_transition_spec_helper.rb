# frozen_string_literal: true

module ProjectsTransitionSpecHelper
  def transitions(project, states)
    states.each { |state| project.update!(status: state) }
  end
end
