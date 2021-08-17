# frozen_string_literal: true

module Projects
  class Assignee
    extend Forwardable
    attr_reader :project, :kam, :assignee_type

    def_delegators :project, :zip, :apartments

    # No need to assign KAM from Kam Region if apartments is less than 50
    APARTMENTS_COUNT_NOT_REQUIRING_KAM = 50

    def initialize(project)
      @project = project
    end

    # We will skip KAM lookup by investor for manual project creations as there is no provision to enter
    # investor ID for the users.
    def call
      @kam = by_kam_investor
      @kam ||= by_kam_region if kam_region_lookup
    end

    private

    def by_kam_investor
      AdminToolkit::KamInvestor
        .find_by(investor_id: investor.id)
        .try(:kam).tap do |kam|
        @assignee_type = :kam if kam
      end
    end

    def investor
      project.address_books.find{|x| x.type == 'investor'}
    end

    def by_kam_region
      penetration = AdminToolkit::Penetration.find_by(zip: zip)
      return unless penetration

      AdminToolkit::KamRegion
        .find_by(id: penetration.kam_region_id)
        .try(:kam)
    end

    def kam_region_lookup
      apartments && apartments > APARTMENTS_COUNT_NOT_REQUIRING_KAM
    end
  end
end
