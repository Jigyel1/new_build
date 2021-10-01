# frozen_string_literal: true

module Projects
  class Building < ApplicationRecord
    belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true
    belongs_to :project, counter_cache: true

    has_one :address, as: :addressable, dependent: :destroy
    has_many :tasks, as: :taskable, class_name: 'Projects::Task', dependent: :destroy
    has_many_attached :files, dependent: :destroy
    accepts_nested_attributes_for :address, allow_destroy: true

    validates :name, :address, presence: true
    validates :external_id, uniqueness: true, allow_nil: true

    after_destroy :update_project
    after_save :update_project

    private

    def update_project
      project.update_column(:apartments_count, project.buildings.sum(:apartments_count))
    end
  end
end
