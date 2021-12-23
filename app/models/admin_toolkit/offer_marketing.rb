# frozen_string_literal: true

module AdminToolkit
  class OfferMarketing < ApplicationRecord
    validates :activity_name, :value, presence: true
  end
end
