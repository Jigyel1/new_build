# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::OfferMarketingsResolver do
  def query
    <<~GQL
      query {
        adminToolkitPcts {
          id status
          pctCost { index min max }
          pctMonth { index min max}
        }
      }
    GQL
  end
end
