module Hooks
  module Project
    extend ActiveSupport::Concern

    NAME = 'System Generated'
    MANUALLY_CREATED = 'Manually Created'

    included do
      after_create :create_default_label_group
    end

    private

    def create_default_label_group
      label_group = label_groups.create!(name: NAME)
      label_group.label_list << MANUALLY_CREATED if manual?
    end
  end
end
