# frozen_string_literal: true

namespace :import do
  desc 'One time import of penetration rates'
  task penetrations: :environment do
    PenetrationImporter.call(input: Rails.root.join('etl/docs/penetrations.xlsx'))
  end
end
