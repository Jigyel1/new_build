# frozen_string_literal: true

module Users
  class UserDeleter < BaseService
    TIME_FORMAT = '%Y_%m_%d_%H_%M'
    include ActivityHelper
    include UserFinder

    attr_accessor :assignee_id, :investor_mappings, :region_mappings

    delegate :kam_regions, :kam_investors, to: :user

    set_callback :call, :before, :validate!
    set_callback :call, :after, :update_email

    # after soft delete reset email so that next time the same user is added
    # you don't get email uniqueness error.
    # also prepending current time to maintain uniqueness of deleted records with same email.
    def call
      authorize! user, to: :delete?, with: UserPolicy

      super do
        with_tracking(activity_id = SecureRandom.uuid, transaction: true) do
          update_associations!
          update_kam_regions!
          update_kam_investors!
          user.discard!

          # Can there be a possibility of a duplicate activity log if the user is already discarded?
          # Short answer - No. By virtue of the default scope where we don't show discarded users,
          # `UserFinder` will throw NotFound error at the very beginning.
          Activities::ActivityCreator.new(activity_params(activity_id, :profile_deleted)).call
        end
      end
    end

    private

    ASSOCIATIONS = %i[assigned_tasks projects assigned_projects].freeze

    # validates <tt>attributes[:assignee_id]</tt> is present when the user to be
    # deleted has assigned tasks or projects.
    def validate!
      return if attributes[:assignee_id].present?
      return if ASSOCIATIONS.flat_map { |association| user.send(association) }.empty?

      raise t('user.assignee_missing')
    end

    def update_associations!
      attrs = %i[assignee_id incharge_id]

      ASSOCIATIONS.each do |association|
        user.send(association).update_all(
          # based on the attribute available for the association the generated attribute can be either
          # <tt>{ :assignee_id => nil/assignee_id }<tt> for <tt>assigned_tasks</tt>
          # <tt>{ :assignee_id => nil/assignee_id, :incharge_id=>nil }</tt> for <tt>projects</tt> and
          # <tt>assigned_projects</tt>
          attrs.each_with_object({}) do |key, hash|
            hash[key] = attributes[:assignee_id] if user.send(association).attribute_method?(key)
          end
        )
      end
    end

    def update_kam_regions!
      update_kam_associations!(kam_regions, :name, :regions) do |association|
        attributes[:region_mappings].find { |mapping| mapping[:kamRegionId] == association.id }[:kamId]
      end
    end

    def update_kam_investors!
      update_kam_associations!(kam_investors, :investor_id, :investors) do |association|
        attributes[:investor_mappings].find { |mapping| mapping[:kamInvestorId] == association.id }[:kamId]
      end
    end

    def update_kam_associations!(associations, interpolation_arg, interpolation_key)
      return unless associations

      keys = associations.pluck(interpolation_arg)
      associations.find_each do |association|
        kam_id = yield(association)
        association.update!(kam_id: kam_id)
      end
    rescue NoMethodError
      raise t("user.kam_with_#{interpolation_key}", references: keys.to_sentence)
    end

    def update_email
      user.update_column(:email, user.email.prepend(Time.current.strftime("#{TIME_FORMAT}_")))
    end
  end
end
