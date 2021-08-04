# frozen_string_literal: true

module Projects
  class Transform
    EXTERNAL_IDS = %w[external_id landlord_id].freeze

    def process(row)
      external_ids = format_external_ids(row)
      hash_attributes = row.compact.except!(*EXTERNAL_IDS)
      external_ids.merge(settings: hash_attributes).with_indifferent_access
    end

    private

    def format_external_ids(row)
      ids = row.slice(*EXTERNAL_IDS)
      ids.update(ids) do |_k, value|
        value.is_a?(Float) ? value.to_i : value
      end
    end
  end
end
