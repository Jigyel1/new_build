# frozen_string_literal: true

module Users
  class StatusUpdater < BaseService
    include UserFinder

    def call
      user.update!(active: attributes[:active])
    end
  end
end
