# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class OfferContentsResolver < SearchObjectBase
      scope { ::AdminToolkit::OfferContent.all }

      type [Types::AdminToolkit::OfferContentType], null: false
    end
  end
end
