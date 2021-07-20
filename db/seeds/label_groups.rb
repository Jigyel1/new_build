# frozen_string_literal: true

# These are the initial default label groups to be created based on the available project stages
#
[
  'New',
  'Technical Analysis',
  'Technical Analysis Finished',
  'Ready to Offer'
].each do |name|
  AdminToolkit::LabelGroup.find_or_create_by!(name: name)
end
