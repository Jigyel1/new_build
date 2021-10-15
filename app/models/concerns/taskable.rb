# frozen_string_literal: true

# This module keeps track of the records previous status.
# In order to include this module in your Active Record class, do ensure that
# your class has an attribute `status`.
module Taskable
  extend ActiveSupport::Concern

  included do
    # When updating task status, make sure to trigger callbacks so that the previous state is properly set.
    # In other words, don't use `task.update_column(:status, :completed)`
    before_save :update_previous_state
  end

  private

  def update_previous_state
    self.previous_status = status_was
  end
end
