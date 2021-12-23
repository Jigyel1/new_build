# frozen_string_literal: true

module AdminToolkit
  class OfferContent < ApplicationRecord
    validates :title, :content, presence: true
  end
end
