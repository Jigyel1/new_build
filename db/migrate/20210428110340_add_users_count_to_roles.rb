# frozen_string_literal: true

class AddUsersCountToRoles < ActiveRecord::Migration[6.1]
  def up
    add_column :roles, :users_count, :integer
    change_column_default :roles, :users_count, 0

    # If the counter cache column is added after records(users/roles) are already available.
    Role.find_each do |role|
      Role.reset_counters(role.id, :users)
    end
  end

  def down
    remove_column :roles, :users_count
  end
end
