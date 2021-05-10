# frozen_string_literal: true

require 'csv'

module Activities
  class ActivityExporter < BaseActivity
    attr_accessor :emails, :dates, :query

    def call
      scoped_activities
        .then { |scope| apply_filter(:email_filter, scope, emails) }
        .then { |scope| apply_filter(:date_filter, scope, dates) }
        .then { |scope| apply_filter(:search, scope, query) }
        .then { |scope| export(scope) }
        .then { |scope| url(scope) }
    end

    private

    def apply_filter(filter, scope, param)
      param.present? ? send("apply_#{filter}", scope, param) : scope
    end

    def export(scope)
      CSV.generate do |csv|
        csv << [t('activities.sl_no'), t('activities.date'), t('activities.time'), t('activities.activity')]

        scope.each.with_index(1).map do |activity, index|
          csv << Exports::PrepareRow.new(current_user: current_user, activity: activity, index: index).call
        end
      end
    end

    # The idea is to save file with cnc-storage and return that url to FE.
    def url(_scope)
      # byebug
      # # Cnc::Storage.by_file(scope)
      #
      # file = File.new(Tempfile.new("export_#{formatted_time(Time.current)}"))
      # begin
      #   file.write(scope)
      #   Cnc::Storage.by_request(file.path)
      # ensure
      #   file.close
      #   file.unlink   # deletes the temp file
      # end
      'a valid url'
    end
  end
end
