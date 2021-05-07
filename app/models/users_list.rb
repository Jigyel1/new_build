# frozen_string_literal: true

class UsersList < ApplicationRecord
  include Discard::Model
  has_one :profile

  self.primary_key = :id

  # this isn't strictly necessary, but it will prevent
  # rails from calling save, which would fail anyway.
  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(:users_list, concurrently: false, cascade: false)
  end
end
