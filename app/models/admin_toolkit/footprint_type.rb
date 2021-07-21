# frozen_string_literal: true

module AdminToolkit
  class FootprintType < ApplicationRecord
    has_many(
      :footprint_values,
      class_name: 'AdminToolkit::FootprintValue',
      dependent: :restrict_with_error
    )

    enum provider: {
      ftth_swisscom: 'Footprint SFN n',
      ftth_sfn: 'No Footprint SFN y',
      both: 'Footprint SFN y',
      neither: 'No Footprint SFN n'
    }

    validates :provider, presence: true
    validates :index, uniqueness: true

    default_scope { order(:index) }
  end
end
