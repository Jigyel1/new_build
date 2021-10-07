# frozen_string_literal: true

HEADERS = %w[factor lease_rate description].freeze

[
  ['FTTH Swisscom', 1.5, 75, 'The best situation'],
  ['FTTH local provider', 1.7, 75, 'The best situation - reloaded'],
  ['Swisscom DSL', 1.9, 75, 'The best situation - ultimatum']
].each do |arr|
  name = arr.shift
  create_record(HEADERS.zip(arr).to_h) { AdminToolkit::Competition.find_or_initialize_by(name: name) }
end
