# frozen_string_literal: true

module Types
  module Projects
    class LabelGroupType < BaseObject
      graphql_name 'ProjectsLabelGroupType' # To avoid naming conflict with LabelGroupType in the AdminToolkit

      field :id, ID, null: true
      field :system_generated, Boolean, null: true
      field :label_group, Types::AdminToolkit::LabelGroupType, null: true
      field :label_list, [String], null: true
    end
  end
end
