# frozen_string_literal: true

namespace :activity do
  desc 'Populate activities with project_id and os_id'
  task populate: :environment do
    Activity.each do |activity|
      next if %w[building_imported project_imported].include? activity.action

      trackable = activity.trackable
      activity.update(project_id: trackable.project_nr) if activity.trackable_type == 'Project'
      activity.update(os_id: trackable.os_id) if activity.trackable_type == 'Projects::Building'
    end

    warning = <<~WARNING
      Updated successfully.
    WARNING

    $stdout.write(warning)
  end
end
