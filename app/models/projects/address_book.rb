# frozen_string_literal: true

module Projects
  class AddressBook < ApplicationRecord
    self.inheritance_column = nil

    belongs_to :project
    has_one :address, as: :addressable, dependent: :destroy
    accepts_nested_attributes_for :address, allow_destroy: true

    enum language: { de: 'D', fr: 'F', it: 'I' }

    enum type: { investor: 'Investor', architect: 'Architect', others: 'Others' }

    validates :type, :name, :display_name, presence: true
    validates :type, uniqueness: { unless: ->(record) { record.others? }, scope: :project_id }

    before_validation :set_display_name

    private

    def set_display_name
      self.display_name = AddressBook.types[type] if %w[investor architect].include?(type)
    end
  end
end
