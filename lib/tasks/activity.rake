# frozen_string_literal: true

namespace :activity do
  desc 'Populate activities with project_id and os_id'
  task populate: :environment do
    Activity.where(project_id: nil, os_id: nil).find_each do |activity|
      next if %w[building_imported project_imported].include? activity.action

      activity.update!(project_id: activity.trackable.project_nr) if activity.trackable_type == 'Project'
      activity.update!(os_id: activity.trackable.os_id) if activity.trackable_type == 'Projects::Building'
    end

    warning = <<~WARNING
      Updated successfully.
    WARNING

    $stdout.write(warning)
  end
end
