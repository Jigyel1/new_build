# frozen_string_literal: true

module AdminToolkit
  class ProjectCost < ApplicationRecord
    include Singleton
    public_class_method :allocate

    validates :index, presence: true, uniqueness: true, inclusion: { in: [0] }

    alias_attribute :standard_connection_cost, :standard

    def self.instance
      @instance ||= find_or_create_by!(index: 0)
    end
  end
end
