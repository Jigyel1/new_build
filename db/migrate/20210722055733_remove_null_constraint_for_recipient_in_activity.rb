# frozen_string_literal: true

class RemoveNullConstraintForRecipientInActivity < ActiveRecord::Migration[6.1]
  def change
    change_column_null :activities, :recipient_id, true
  end
end
