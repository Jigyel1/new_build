ActiveSupport::Notifications.subscribe('user_listing') do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  puts "time taken to execute #{event.name} => #{event.duration * 1000} milliseconds." \
         "with payload #{event.payload}"
end
