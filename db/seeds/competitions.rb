# frozen_string_literal: true

HEADERS = %w[factor lease_rate description].freeze

[
  ['FTTH SC & EVU', 0.7, 75, 'Very high competition (fiber areas such as Zurich, Bern, Lucerne, etc.)'],
  ['FTTH SC', 0.8, 75, 'With only FTTH from Swisscom (ALO; especially Salt & Sunrise)'],
  ['FTTH EVU', 0.9, 75, 'With only FTTH of the EVU (Open Access Layer 1 & 2; tendency rather Salt & Sunrise)'],
  ['G.fast', 1.1, 75, 'Suitable competitive situation for UPC'],
  ['VDSL', 1.3, 75, 'Very good situation for UPC'],

  # The factor, lease_rate & descriptions are dummy. To be updated once BAs provide actual data.
  ['FTTH Swisscom', 1.5, 75, 'The best situation'],
  ['FTTH SFN', 1.7, 75, 'The best situation - reloaded'],
  ['f.fast', 1.9, 75, 'The best situation - ultimatum']
].each do |arr|
  name = arr.shift
  create_record(HEADERS.zip(arr).to_h) { AdminToolkit::Competition.find_or_initialize_by(name: name) }
end
