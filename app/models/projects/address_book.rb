# frozen_string_literal: true

module Projects
  class AddressBook < ApplicationRecord
    belongs_to :project

    enum language: { en: 'EN', de: 'DE', fr: 'FR', it: 'IT' }
  end
end
