# frozen_string_literal: true

class AddUsersCountToRoles < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      change_table :roles, bulk: true do |t|
        t.integer :users_count, null: false, default: 0
      end
    end

    # If the counter cache column is added after records(users/roles) are already available.
    Role.find_each do |role|
      Role.reset_counters(role.id, :users)
    end
  end

  def down
    remove_column :roles, :users_count
  end
end
