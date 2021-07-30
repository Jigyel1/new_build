# frozen_string_literal: true

module AdminToolkit
  class ProjectCost < ApplicationRecord
    include Singleton

    validates :index, presence: true, uniqueness: true, inclusion: { in: [0] }

    def self.instance
      @instance ||= find_or_create_by!(index: 0)
    end
  end
end
