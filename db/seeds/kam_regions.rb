# frozen_string_literal: true

Rails.application.config.kam_regions.each do |name|
  AdminToolkit::KamRegion.find_or_create_by(name: name)
end
