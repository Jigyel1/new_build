# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class OfferMarketingsResolver < SearchObjectBase
      scope { ::AdminToolkit::OfferMarketing.all }

      type [Types::AdminToolkit::OfferMarketingType], null: false
    end
  end
end
