# frozen_string_literal: true

class AddManuallyCreatedLabelsToProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :projects, :manually_created_labels, :text, array: true, default: []
    end
  end
end
