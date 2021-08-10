# frozen_string_literal: true

module Projects
  class InvestorPopulator < BasePopulator
    include AddressBookHelper
    include DefaultRoleHelper
  end
end
