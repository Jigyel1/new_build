class AdminToolkit::FootprintType < ApplicationRecord
  enum provider: {
    ftth_swisscom: 'Footprint SFN n',
    ftth_sfn: 'No Footprint SFN y',
    both: 'Footprint SFN y',
    neither: 'No Footprint SFN n'
  }
end
