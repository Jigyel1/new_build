# frozen_string_literal: true

module Projects
  class AddressBook < ApplicationRecord
    self.inheritance_column = nil

    belongs_to :project
    has_one :address, as: :addressable, dependent: :destroy
    accepts_nested_attributes_for :address, allow_destroy: true

    enum language: { en: 'EN', de: 'DE', fr: 'FR', it: 'IT' }
    enum type: { investor: 'Investor', architect: 'Architect' }

    validates :type, :name, :company, :phone, :mobile, :email, :website, presence: true
    validates :type, uniqueness: { scope: :project_id }
  end
end
