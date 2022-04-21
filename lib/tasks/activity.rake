# frozen_string_literal: true

ACTIONS = %w[Project Projects::Building].freeze

namespace :activity do
  desc 'Populate activities with project_id and os_id'
  task populate: :environment do
    Activity.where(project_id: nil, os_id: nil).find_each do |activity|
      next if ACTIONS.include?(activity.action)

      trackable = activity.trackable
      activity.update(project_id: trackable.try(:project_nr)) if activity.trackable_type == 'Project'
      activity.update(project_external_id: trackable.external_id) if activity.trackable_type == 'Project'
      activity.update(os_id: trackable.try(:external_id)) if activity.trackable_type == 'Projects::Building'
    end

    warning = <<~WARNING
      Updated successfully.
    WARNING

    $stdout.write(warning)
  end
end
