# frozen_string_literal: true

class AddAdditionalCommentsToProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :projects, :additional_comments, :text
    end
  end
end
