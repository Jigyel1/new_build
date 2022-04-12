# frozen_string_literal: true

namespace :verdict do
  desc 'Fills the empty null value of verdict with empty object'
  task replace_null: :environment do
    Project.where(verdicts: nil).find_each do |project|
      project.update!(verdicts: {})
    end
    warning = <<~WARNING
      Updated successfully.
    WARNING

    $stdout.write(warning)
  end
end
