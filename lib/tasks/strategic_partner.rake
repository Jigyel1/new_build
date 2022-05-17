# frozen_string_literal: true

namespace :strategic_partner do
  desc 'Populate projects with strategic_partners'
  task populate: :environment do
    Project.all do |project|
      strategic_partner = AdminToolkit::Penetration.find_by(zip: project.zip).strategic_partner
      project.update!(strategic_partner: strategic_partner)
    end

    warning = <<~WARNING
      Updated successfully.
    WARNING

    $stdout.write(warning)
  end
end
