# frozen_string_literal: true

module Projects
  class ArchitectPopulator < BasePopulator
    include AddressBookAssigner
    include DefaultRoleHelper
  end
end
