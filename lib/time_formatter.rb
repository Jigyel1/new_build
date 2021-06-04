# frozen_string_literal: true

module TimeFormatter
  refine ActiveSupport::TimeWithZone do
    def date_str
      strftime('%d %B %Y')
    end

    def time_str
      strftime('%H:%M:%S')
    end
  end

  refine Time do
    def datetime_str
      strftime('%d %B %Y at %H:%M:%S')
    end
  end
end
