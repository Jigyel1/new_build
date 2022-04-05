# frozen_string_literal: true

namespace :gis do
  desc 'Recalculate the payback for null paybacks.'
  task populate: :environment do
    Project.where(entry_type: :manual, gis_url: nil).each do |project|
      project.update!(
        gis_url: Rails.application.config.gis_url_static
      )
    end
  end
end
