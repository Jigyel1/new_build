# frozen_string_literal: true

module Users
  class UserUpdater < BaseService
    include UserFinder

    private

    def process
      authorize! current_user, to: :update?, with: UserPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        user.update!(attributes)

        Activities::ActivityCreator.new(
          activity_params(activity_id, :profile_updated, attributes)
        ).call
      end
    end

    def execute?
      %i[profile address].any? do |association|
        keys, values = attributes["#{association}_attributes"].to_a.transpose
        old_values = user.send(association).attributes.values_at(*keys)
        values != old_values
      end
    end
  end
end
