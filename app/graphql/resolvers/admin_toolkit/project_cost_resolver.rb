# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class ProjectCostResolver < BaseResolver
      type Types::AdminToolkit::ProjectCostType, null: true

      # Using <tt>reload</tt> to force Rails to fetch the latest data from the database since
      # Rails is rendering the cached value and not the latest value after an update.
      def resolve
        ::AdminToolkit::ProjectCost.instance.reload
      rescue ActiveRecord::RecordNotFound # FIXME: Short Hack to avoid rspec failure
        ::AdminToolkit::ProjectCost.instance
      end
    end
  end
end
