# frozen_string_literal: true

module AdminToolkit
  class LabelGroup < ApplicationRecord
    acts_as_taggable_on :labels

    # validates :label_list, uniqueness: true #{ case_sensitive: false }
    validates :name, presence: true, uniqueness: true # inclusion: { in: Project.statuses } => Once project is ready!
  end
end
