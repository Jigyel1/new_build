# frozen_string_literal: true

ActiveSupport::Notifications.subscribe('user_listing') do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.info "time taken to execute #{event.name} => #{(event.duration * 1000).round} milliseconds." \
         "with payload #{event.payload}"
end
