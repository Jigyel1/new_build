# frozen_string_literal: true

module Projects
  class RoleType3Populator < BasePopulator
    include AddressBookAssigner
    include CustomRoleHelper
  end
end
