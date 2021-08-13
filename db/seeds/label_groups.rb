# frozen_string_literal: true

# These are the initial default label groups to be created based on the available project stages
#
{
  technical_analysis: 'Technical Analysis',
  pct_calculation: 'PCT Calculation',
  technical_analysis_completed: 'Technical Analysis Completed/On-Hold Meeting',
  ready_for_offer: 'Ready for Offer',
  contract: 'Contract',
  contract_accepted: 'Contract Accepted',
  under_construction: 'Under Construction'
}.each_pair do |code, name|
  AdminToolkit::LabelGroup.find_or_create_by!(code: code, name: name)
end
