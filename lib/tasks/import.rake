namespace :import do
  desc "TODO"
  task penetrations: :environment do
    Penetration.call(pathname: Rails.root.join('etl/docs/penetrations.xlsx'))
  end
end
