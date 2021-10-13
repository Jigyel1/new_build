# frozen_string_literal: true

module Accessors
  module AdminToolkitActivity
    extend ActiveSupport::Concern

    included do
      store :log_data, accessors: %i[recipient_email owner_email parameters], coder: JSON

      store :parameters, accessors: %i[
        name
        zip
        label_list
        standard
        max
        min
        investor_id
      ], coder: JSON
    end
  end
end
