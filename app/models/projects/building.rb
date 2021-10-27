# frozen_string_literal: true

module Projects
  class Building < ApplicationRecord
    belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true
    belongs_to :project, counter_cache: true

    has_one :address, as: :addressable, dependent: :destroy
    has_many :tasks, as: :taskable, class_name: 'Projects::Task', dependent: :destroy
    has_many_attached :files, dependent: :destroy
    accepts_nested_attributes_for :address, allow_destroy: true

    delegate :name, to: :project, prefix: true
    delegate :buildings, to: :project

    validates :name, :address, presence: true
    validates :external_id, uniqueness: true, allow_nil: true
    validates :move_in_ends_on, end_date: true, allow_nil: true

    after_destroy :update_project
    after_save :update_project

    private

    # Project's <tt>move_in_starts_on</tt> should be the earliest of the <tt>move_in_starts_on</tt> of
    # it's buildings and <tt>move_in_ends_on</tt> should be the latest of the <tt>move_in_ends_on</tt>
    # of it's buildings.
    def update_project
      move_in_starts_on = buildings.minimum(:move_in_starts_on) || project.move_in_starts_on
      move_in_ends_on = buildings.maximum(:move_in_ends_on) || project.move_in_ends_on

      project.update_columns(
        apartments_count: buildings.sum(:apartments_count),
        move_in_starts_on: move_in_starts_on,
        move_in_ends_on: move_in_ends_on
      )
    end
  end
end
