# frozen_string_literal: true

class ChangeCustomerRequestDefaultInProjects < ActiveRecord::Migration[6.1]
  def change
    change_column_default :projects, :customer_request, from: nil, to: true
  end
end
