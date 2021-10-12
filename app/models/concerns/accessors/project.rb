# frozen_string_literal: true

module Accessors
  module Project
    extend ActiveSupport::Concern
    ACCESSORS = %i[
      site_area
      base_area
      purpose
      main_category
      cat_code_01
      cat_text_01
      cat_art_01
      cat_code_02
      cat_text_02
      project_text_part_01
      project_text_part_02
      project_text_part_03
      proj_extern_id
      prod_id
      geocod_sccs
      coord_e
      coord_n
      regi_keyaccountmanager_name
      previous_status
      incharge_email
      label_list
      status
      role_type
      filename
      project_name
      title
      entry_type
      type
      copy
    ].freeze

    included do
      store :additional_details, accessors: ACCESSORS, coder: JSON
    end
  end
end
