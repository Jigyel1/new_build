# frozen_string_literal: true

module Projects
  class ProjectConnectionCost < BaseService
    attr_accessor :cost, :type, :connection_type, :cost_type

    def call
      if cost.present? && type.present?
        type.update!(cost_type: cost_type)
        type
      else
        cost.find_or_create_by!(
          connection_type: connection_type,
          cost_type: cost_type
        )
      end
    end
  end
end
