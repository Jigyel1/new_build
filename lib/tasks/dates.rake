# frozen_string_literal: true

namespace :dates do
  desc 'Recalculate the payback for null paybacks.'
  task populate: :environment do
    Project.where(move_in_ends_on: nil).each do |project|
      next if project.buildings.blank?

      project.update!(
        move_in_starts_on: project.buildings.minimum(:move_in_starts_on),
        move_in_ends_on: project.buildings.maximum(:move_in_starts_on)
      )
    end
  end
end
