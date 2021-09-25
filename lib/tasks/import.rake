# frozen_string_literal: true

namespace :import do
  desc 'One time import of penetration rates'
  task penetrations: :environment do
    PenetrationImporter.call(input: Rails.root.join('etl/docs/penetrations.xlsx'))
  end

  # To test the import as a rake task, uncomment the below and try it.
  desc 'Import projects from a shared excel'
  task :projects, [:filepath] => [:environment] do |_task, _args|
    ProjectsImporter.call(input: File.new(Rails.root.join('etl/docs/projects-test.xlsx')), current_user: User.first)
  end

  # To test the import as a rake task, uncomment the below and try it.
  desc 'Import buildings from a shared excel'
  task :buildings, [:filepath] => [:environment] do |_task, _args|
    BuildingsImporter.call(input: File.new(Rails.root.join('etl/docs/buildings-test.xlsx')), current_user: User.first)
  end
end

# look at thor as a drop in replacement for rake
# https://technology.doximity.com/articles/move-over-rake-thor-is-the-new-king
