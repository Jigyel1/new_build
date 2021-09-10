# frozen_string_literal: true

module Resolvers
  module Projects
    class FilesResolver < SearchObjectBase
      VALID_TASKABLE_TYPES = ['Project', 'Projects::Building'].freeze

      scope do
        ActiveStorage::Attachment
      end

      type Types::Projects::FileConnectionType, null: false

      option :attachable, type: [String], with: :apply_attachable_filter, required: true, description: <<~DESC
        Takes in two arguments. First, the attachable id(project or the building id).
        Second, the attachable type(when project then `Project`, when building then `Projects::Building`). 
        Note that this option is mandatory!
      DESC

      option(:owner_ids, type: [String]) {|scope, value| scope.where(owner_id: value)}
      option :query, type: String, with: :apply_search

      def apply_attachable_filter(scope, value)
        attachable_id, attachable_type = value
        raise I18n.t('projects.file.invalid_attachable_type', valid_types: VALID_TASKABLE_TYPES.to_sentence) unless VALID_TASKABLE_TYPES.include?(attachable_type)

        scope.where(record_id: attachable_id, record_type: attachable_type)
      end

      def apply_search(scope, value)
        scope.joins(:blob, owner: :profile).where(
          "CONCAT_WS(
          ' ',
          profiles.firstname,
          profiles.lastname,
          active_storage_blobs.filename,
          active_storage_attachments.created_at
        )
        iLIKE ?", "%#{value.squish}%"
        )
      end
    end
  end
end
