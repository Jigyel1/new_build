# frozen_string_literal: true

HEADERS = %w[code sfn factor lease_rate description calculation_type].freeze

# TODO: Add proper descriptions. BA yet to provide those.
[
  ['SFN/Big4', :sfn, false, 1.5, 75, 'The best situation', 'SFN/Big4'],
  ['Swisscom FTTH', :ftth, true, 1.7, 75, 'The best situation - reloaded', 'Swisscom FTTH'],
  ['Swisscom DSL', :dsl, false, 1.9, 75, 'The best situation - ultimatum', 'Swisscom DSL'],
  ['Unknown', :unknown, false, 1.9, 75, 'The best situation - ultimatum', 'SFN/Big4']
].each do |arr|
  name = arr.shift
  create_record(HEADERS.zip(arr).to_h) { AdminToolkit::Competition.find_or_initialize_by(name: name) }
end
