# frozen_string_literal: true

namespace :dates do
  desc 'Recalculate the payback for null paybacks.'
  task populate: :environment do
    Project.where(move_in_ends_on: nil).each do |project|
      next if project.buildings.blank?

      dates = project.buildings.group_by(&:move_in_starts_on).keys.minmax
      start_date, end_date = dates

      project.update!(move_in_starts_on: start_date, move_in_ends_on: end_date)
    end
  end
end
