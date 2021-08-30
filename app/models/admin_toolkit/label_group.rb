# frozen_string_literal: true

module AdminToolkit
  class LabelGroup < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    # validates :name, inclusion: { in: Project.statuses.values }, on: :create

    def label_list=(value)
      return unless value

      super(value.split(',').map(&:strip).uniq)
    end
  end
end
