# frozen_string_literal: true

class ProjectsList < ApplicationRecord
  has_one :addresss

  self.primary_key = :id

  # this isn't strictly necessary, but it will prevent
  # rails from calling save, which would fail anyway.
  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(:projects_list, concurrently: false, cascade: false)
  end
end
