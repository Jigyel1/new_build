# frozen_string_literal: true

# This migration comes from telco_uam (originally 20210302101250)

class EnableUuid < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'pgcrypto'
  end
end
