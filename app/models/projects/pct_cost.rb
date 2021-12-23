# frozen_string_literal: true

module Projects
  class PctCost < ApplicationRecord
    belongs_to :connection_cost, class_name: 'Projects::ConnectionCost'

    delegate :name, to: :project, prefix: true

    # FIXME: Validate that connection cost - cost type is not `too_expensive`
  end
end
