# frozen_string_literal: true

namespace :import do
  desc 'One time import of penetration rates'
  task penetrations: :environment do
    PenetrationsImporter.call(input: Rails.root.join('etl/docs/penetrations.xlsx'))
  end

  # Run this task only in your dev/test environments.
  # In prod, projects will be created/imported through a file upload.
  desc 'Import projects from a shared excel'
  task projects: :environment do
    abort('This can be run only on test servers!') unless ENV.fetch('TEST_SERVER', '').to_b

    ProjectsImporter.call(input: File.new(Rails.root.join('etl/docs/projects.xlsx')), current_user: User.first)
  end

  # Run this task only in your dev/test environments.
  # In prod, buildings will be uploaded/imported through a file upload.
  desc 'Import buildings from a shared excel'
  task buildings: :environment do
    abort('This can be run only on test servers!') unless ENV.fetch('TEST_SERVER', '').to_b

    BuildingsImporter.call(input: File.new(Rails.root.join('etl/docs/buildings.xlsx')), current_user: User.first)
  end
end
