# frozen_string_literal: true

module AdminToolkit
  class LabelGroup < ApplicationRecord
    validates :name, presence: true, uniqueness: true # inclusion: { in: Project.statuses } => Once project is ready!

    def label_list=(value)
      return unless value

      super(value.split(',').map(&:strip).uniq)
    end
  end
end
