# frozen_string_literal: true

module Types
  module AdminToolkit
    class LabelGroupType < BaseObject
      field :id, ID, null: true
      field :name, String, null: true
      field :label_list, [String], null: true
      #
      # def label_list
      #   byebug
      # end
    end
  end
end
