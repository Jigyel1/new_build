module Buildings
  module Helper
    def lookup_hash(row)
      if row[PROJECT_EXTERNAL_ID]
        { external_id: row[PROJECT_EXTERNAL_ID].to_i }
      else
        { internal_id: row[PROJECT_INTERNAL_ID].to_i }
      end
    end

    def attributes_hash(row, attributes)
      attributes.keys.zip(row.values_at(*attributes.values)).to_h
    end
  end
end