# frozen_string_literal: true

module Projects
  class InvestorPopulator < BasePopulator
    include AddressBookAssigner
    include DefaultRoleHelper
  end
end
