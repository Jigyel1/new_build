# frozen_string_literal: true

module TimeFormatter
  refine ActiveSupport::TimeWithZone do
    def date_str
      strftime('%d.%m.%Y')
    end

    def time_str
      strftime('%H:%M:%S')
    end

    def datetime_str
      strftime('%d %B %Y at %H:%M:%S')
    end
  end
end
