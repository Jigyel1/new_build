class AddLogidzeToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :log_data, :jsonb

    safety_assured do
      reversible do |dir|
        dir.up do
          execute <<~SQL
            CREATE TRIGGER logidze_on_profiles
            BEFORE UPDATE OR INSERT ON profiles FOR EACH ROW
            WHEN (coalesce(current_setting('logidze.disabled', true), '') <> 'on')
            -- Parameters: history_size_limit (integer), timestamp_column (text), filtered_columns (text[]),
            -- include_columns (boolean), debounce_time_ms (integer)
            EXECUTE PROCEDURE logidze_logger(null, 'updated_at', '{salutation,firstname,lastname,phone,department}', true);

          SQL
        end

        dir.down do
          execute "DROP TRIGGER IF EXISTS logidze_on_profiles on profiles;"
        end
      end
    end
  end
end
