# frozen_string_literal: true

require 'csv'

module Activities
  class ActivityExporter < BaseActivity
    attr_accessor :user_ids, :actions, :dates, :query

    def call
      scoped_activities
        .then { |scope| apply_filter(:user_filter, scope, :user_ids) }
        .then { |scope| apply_filter(:trackable_id_filter, scope, :trackable_id) }
        .then { |scope| apply_filter(:action_filter, scope, :actions) }
        .then { |scope| apply_filter(:date_filter, scope, :dates) }
        .then { |scope| apply_filter(:search, scope, :query) }
        .then { |scope| export(scope) }
        .then { |scope| url(scope) }
    end

    private

    def apply_filter(filter, scope, param)
      value = attributes.send(param)
      value.present? ? send("apply_#{filter}", scope, value) : scope
    end

    def export(scope)
      CSV.generate do |csv|
        csv << [t('activities.sl_no'), t('activities.date'), t('activities.time'), t('activities.activity')]

        scope.each.with_index(1).map do |activity, index|
          csv << Exports::PrepareRow.new(current_user: current_user, activity: activity, index: index).call
        end
      end
    end

    def url(scope)
      current_user.activity_download.attach(
        io: StringIO.new(scope),
        filename: 'user_activities.csv',
        content_type: 'application/csv'
      ).then do |attached|
        attached && url_for(current_user.activity_download)
      end
    end
  end
end
