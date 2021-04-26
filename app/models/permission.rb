# frozen_string_literal: true

class Permission < ApplicationRecord
  belongs_to :accessor, polymorphic: true

  validates :resource, presence: true, uniqueness: { scope: :accessor }
  validates :actions, permission_actions: true
end
