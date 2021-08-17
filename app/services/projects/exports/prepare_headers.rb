module Projects
  module Exports
    class PrepareHeaders
      attr_reader :csv_headers, :projects

      def initialize(csv_headers, projects)
        @csv_headers = csv_headers
        @projects = projects
      end

      def call
        load_default_headers
        load_address_book_headers
        headers.flatten
      end

      def headers
        @headers ||= []
      end

      private

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
          .where(address_books: { type: :others})
          .order('projects.id')
          .group('projects.id')
          .count
          .values
          .max
      end

      def other_headers(index, type)
        gsub_x = ->(headers) { headers.gsub('X', "#{index}") }
        csv_headers[type].values.map(&gsub_x)
      end
    end
  end
end
