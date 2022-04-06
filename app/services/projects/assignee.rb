# frozen_string_literal: true

module Projects
  class Assignee < BaseService
    extend Forwardable
    attr_reader :kam, :assignee_type
    attr_accessor :project

    def_delegators :project, :zip, :apartments_count

    # We will skip KAM lookup by investor for manual project creations as there is no provision to enter
    # investor ID for the users.
    def call
      @kam = by_kam_investor
      @kam ||= by_kam_region if kam_region_lookup

      return if kam.blank?

      project.assignee = kam
      notify_assignee
    end

    private

    def by_kam_investor
      AdminToolkit::KamInvestor
        .find_by(investor_id: investor.try(:external_id))
        .try(:kam).tap do |kam|
        @assignee_type = :kam if kam
      end
    end

    def investor
      project.address_books.find { |x| x.type == 'investor' }
    end

    def by_kam_region
      penetration = AdminToolkit::Penetration.find_by(zip: zip)
      return unless penetration

      AdminToolkit::KamRegion
        .find_by(id: penetration.kam_region_id)
        .try(:kam).tap do |kam|
        @assignee_type = :kam if kam
      end
    end

    # No need to assign KAM from Kam Region if apartments is less than 50
    APARTMENTS_COUNT_NOT_REQUIRING_KAM = 50
    def kam_region_lookup
      apartments_count && apartments_count > APARTMENTS_COUNT_NOT_REQUIRING_KAM
    end

    def notify_assignee
      ProjectMailer.notify_project_assigned(project.assignee_id, project.id).deliver_later
    end
  end
end
