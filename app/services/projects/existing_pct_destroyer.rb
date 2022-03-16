# frozen_string_literal: true

module Projects
  class ExistingPctDestroyer < BaseService
    attr_accessor :attributes

    def call
      ::Projects::ConnectionCost.find_by(project_id: attributes[:project_id]).try(:destroy)
    end
  end
end
