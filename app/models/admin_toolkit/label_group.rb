# frozen_string_literal: true

module AdminToolkit
  class LabelGroup < ApplicationRecord
    validates :name, :code, presence: true, uniqueness: true
    validates :code, inclusion: { in: Project.statuses.keys }
    validates :label_list, label_list: true

    default_scope { order(code: :asc) }

    def label_list=(value)
      return unless value

      super(value.to_a_uniq)
    end
  end
end
