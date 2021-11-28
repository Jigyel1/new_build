# frozen_string_literal: true

class RemoveNullConstraintForNameFromAddressBooks < ActiveRecord::Migration[6.1]
  def change
    change_column_null :projects_address_books, :name, true
  end
end
