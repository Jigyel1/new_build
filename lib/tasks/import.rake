# frozen_string_literal: true

namespace :import do
  desc 'One time import of penetration rates'
  task penetrations: :environment do
    PenetrationImporter.call(input: Rails.root.join('etl/docs/penetrations.xlsx'))
  end

  # # To test the import as a rake task, uncomment the below and try it.
  # desc 'Import projects from a shared excel'
  # task :projects, [:filepath] => [:environment] do |_task, args|
  #   ProjectsImporter.call(input: File.new(Rails.root.join('etl/docs/projects.xlsx')), current_user: User.first)
  # end
end
