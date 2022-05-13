# frozen_string_literal: true

module Projects
  class AddressBook < ApplicationRecord
    include Discard::Model

    self.inheritance_column = nil

    belongs_to :project, counter_cache: true
    has_one :address, as: :addressable, dependent: :destroy
    accepts_nested_attributes_for :address, allow_destroy: true

    enum language: { de: 'D', fr: 'F', it: 'I' }
    enum type: { investor: 'Building Owner', architect: 'Architect', others: 'Others' }
    enum entry_type: { manual: 'Manual', info_manager: 'Info Manager' }

    validates :type, :display_name, presence: true
    validates :type, uniqueness: { unless: :others?, scope: :project_id }
    validates_with AnyPresenceValidator, fields: %i[name company]

    delegate :name, to: :project, prefix: true

    before_validation :set_display_name
    after_destroy :update_projects_list
    after_save :update_projects_list, :update_users_list

    default_scope { kept }

    # If the given address book is a main contact for the project, prefix it with character `c`
    def external_id_with_contact
      main_contact? ? "c#{external_id}" : external_id
    end

    private

    def set_display_name
      self.display_name = AddressBook.types[type] if %w[investor architect].include?(type)
    end
  end
end
