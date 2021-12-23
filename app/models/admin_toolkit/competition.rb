# frozen_string_literal: true

module AdminToolkit
  class Competition < ApplicationRecord
    validates :name, :factor, :lease_rate, presence: true
    validates :name, uniqueness: { case_sensitive: false }
    validates :factor, numericality: { greater_than_or_equal_to: 0 }

    has_many :projects, dependent: :restrict_with_error
    has_many :penetration_competitions, class_name: 'AdminToolkit::PenetrationCompetition' # rubocop:disable Rails/HasManyOrHasOneDependent
    has_many :penetrations, through: :penetration_competitions, dependent: :restrict_with_error

    default_scope { order(created_at: :desc) }

    before_commit :set_code, on: :create

    private

    def set_code
      self.code ||= name.parameterize.underscore
    end
  end
end
