# frozen_string_literal: true

module Projects
  module Exports
    class PrepareHeaders < BaseService
      attr_accessor :csv_headers, :projects

      def call
        %i[default address_book].each { |type| send("load_#{type}_headers") }
        headers.flatten
      end

      private

      def headers
        @_headers ||= []
      end

      def load_default_headers
        %i[project investor architect].each do |type|
          headers << csv_headers[type].values
          headers << csv_headers["#{type}_address"].values
        end
      end

      def load_address_book_headers
        other_role_types_count.times.with_index(3) do |_counter, index|
          headers << other_headers(index, :others)
          headers << other_headers(index, :others_address)
        end
      end

      # Get the max count of associated address books for projects where the type is `:others`
      def other_role_types_count
        projects
          .joins(:address_books)
          .where(address_books: { type: :others })
          .order('projects.id')
          .group('projects.id')
          .count
          .values
          .max || 0
      end

      def other_headers(index, type)
        gsub_x = ->(headers) { headers.gsub('X', index.to_s) }
        csv_headers[type].values.map(&gsub_x)
      end
    end
  end
end
