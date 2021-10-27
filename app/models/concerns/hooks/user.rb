# frozen_string_literal: true

module Hooks
  module User
    extend ActiveSupport::Concern

    included do
      after_save :update_mat_view
      after_destroy :update_mat_view

      after_discard :validate_kam_regions, :validate_kam_investors
    end

    private

    def update_mat_view
      UsersList.refresh
      ProjectsList.refresh
    end

    def validate_kam_regions
      return if kam_regions.empty?

      raise I18n.t('user.kam_with_regions', references: kam_regions.pluck(:name).to_sentence)
    end

    def validate_kam_investors
      return if kam_investors.empty?

      raise I18n.t('user.kam_with_investors', references: kam_investors.pluck(:investor_id).to_sentence)
    end
  end
end
