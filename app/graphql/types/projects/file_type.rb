# frozen_string_literal: true

module Types
  module Projects
    class FileType < BaseObject
      field :id, ID, null: true
      field :record_type, String, null: true
      field :record_id, String, null: true
      field :blob_id, String, null: true
      field :owner, Types::UserType, null: true

      field :name, String, null: true
      def name
        object.blob.filename
      end

      field :size, Float, null: true, description: 'Returns size in MB'
      def size
        (object.blob.byte_size / 1000.0).rounded
      end

      field :file_url, String, null: true
      def file_url
        rails_blob_path(object)
      end

      field :created_at, String, null: true
      def created_at
        in_time_zone(:created_at)
      end
    end
  end
end
