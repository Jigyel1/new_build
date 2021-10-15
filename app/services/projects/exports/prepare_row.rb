# frozen_string_literal: true

module Projects
  module Exports
    class PrepareRow < BaseService
      attr_accessor :project, :csv_headers

      def call
        load_default_values
        load_address_books_values

        # replace all commas with a space so that it does not screw-up the formatting.
        gsub_comma = ->(headers) { headers.to_s.tr(',', ' ') }
        values.flatten.map(&gsub_comma)
      end

      private

      def values
        @_values ||= []
      end

      def load_default_values # rubocop:disable Metrics/AbcSize
        %i[project investor architect].each do |type|
          values << csv_headers[type].keys.map { |attr| setter { send(type).try(attr) } }
          values << csv_headers["#{type}_address"].keys.map { |attr| setter { send(type)&.address.try(attr) } }
        end
      end

      def load_address_books_values # rubocop:disable Metrics/AbcSize
        project.address_books.where(type: :others).each do |address_book|
          values << csv_headers[:others].keys.map { |attr| setter { address_book.try(attr) } }
          values << csv_headers[:others_address].keys.map { |attr| setter { address_book.address.try(attr) } }
        end
      end

      def investor
        project.address_books.find_by!(type: :investor)
      end

      def architect
        project.address_books.find_by!(type: :architect)
      end

      def setter
        yield || ''
      end
    end
  end
end
