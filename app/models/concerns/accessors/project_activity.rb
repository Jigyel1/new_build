# frozen_string_literal: true

module Accessors
  module ProjectActivity
    extend ActiveSupport::Concern

    included do
      store :log_data, accessors: %i[recipient_email owner_email parameters], coder: JSON

      store :parameters, accessors: %i[
        name
        previous_status
        incharge_email
        label_list
        status
        address_book_type
        filename
        project_name
        title
        entry_type
        type
        copy
      ], coder: JSON
    end
  end
end
