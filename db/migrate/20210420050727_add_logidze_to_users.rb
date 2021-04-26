# frozen_string_literal: true

class AddLogidzeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :telco_uam_users, :log_data, :jsonb

    safety_assured do
      reversible do |dir|
        dir.up do
          execute <<~SQL.squish
            CREATE TRIGGER logidze_on_telco_uam_users
            BEFORE UPDATE OR INSERT ON telco_uam_users FOR EACH ROW
            WHEN (coalesce(current_setting('logidze.disabled', true), '') <> 'on')
            -- Parameters: history_size_limit (integer), timestamp_column (text), filtered_columns (text[]),
            -- include_columns (boolean), debounce_time_ms (integer)
            EXECUTE PROCEDURE logidze_logger(null, 'updated_at', '{active,email,invitation_created_at}', true);
          SQL
        end

        dir.down do
          execute 'DROP TRIGGER IF EXISTS logidze_on_telco_uam_users on telco_uam_users;'
        end
      end
    end
  end
end
