# frozen_string_literal: true

module AdminToolkit
  class LabelGroup < ApplicationRecord
    validates :name, :code, presence: true, uniqueness: true
    validates :code, inclusion: { in: Project.statuses.keys }

    default_scope { order(code: :asc) }

    def label_list=(value)
      return unless value

      super(value.split(',').map(&:strip).uniq)
    end
  end
end
