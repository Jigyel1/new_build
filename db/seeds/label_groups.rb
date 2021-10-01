# frozen_string_literal: true

# These are the initial default label groups to be created based on the available project stages
Project.statuses.each_pair do |code, name|
  AdminToolkit::LabelGroup.find_or_create_by!(code: code, name: name)
end
