# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  protected

  def update_projects_list
    UsersList.refresh
  end

  def update_users_list
    ProjectsList.refresh
  end
end
