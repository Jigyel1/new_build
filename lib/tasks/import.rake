# frozen_string_literal: true

namespace :import do
  desc 'One time import of penetration rates'
  task penetrations: :environment do
    PenetrationImporter.call(pathname: Rails.root.join('etl/docs/penetrations.xlsx'))
  end

  desc 'Import projects from a shared excel'
  task projects: :environment do
    ProjectImporter.call(pathname: Rails.root.join('etl/docs/projects.xlsx'))
  end
end
