# frozen_string_literal: true

AdminToolkit::KamRegion.insert_all(
  Rails.application.config.kam_regions.map do |name|
    { name: name, created_at: Time.zone.now, updated_at: Time.zone.now }
  end
)
