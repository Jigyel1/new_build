# frozen_string_literal: true

module Projects
  class RoleType4Populator < BasePopulator
    include AddressBookAssigner
    include CustomRoleHelper
  end
end
