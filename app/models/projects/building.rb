# frozen_string_literal: true

module Projects
  class Building < ApplicationRecord
    include Discard::Model

    belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true
    belongs_to :project, counter_cache: true

    has_one :address, as: :addressable, dependent: :destroy
    has_many :tasks, as: :taskable, class_name: 'Projects::Task', dependent: :destroy
    has_many_attached :files, dependent: :destroy
    accepts_nested_attributes_for :address, allow_destroy: true

    delegate :name, to: :project, prefix: true
    delegate :buildings, to: :project

    validates :external_id, uniqueness: true, allow_nil: true
    validates :apartments_count, numericality: { greater_than: 0 }, presence: true

    default_scope { kept }

    after_destroy :update_project!
    after_save :update_project!

    private

    def update_project!
      dates = buildings.group_by(&:move_in_starts_on).keys.compact.minmax
      start_date, end_date = dates

      project.update!(
        move_in_starts_on: start_date,
        move_in_ends_on: end_date,
        apartments_count: buildings.sum(:apartments_count)
      )
    end
  end
end
