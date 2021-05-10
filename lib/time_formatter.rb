# frozen_string_literal: true

module TimeFormatter
  def formatted_date(timestamp)
    timestamp.strftime('%d %B %Y')
  end

  def formatted_time(timestamp)
    timestamp.strftime('%H:%M:%S')
  end

  def formatted_datetime(timestamp)
    timestamp.strftime('%d %B %Y at %H:%M:%S')
  end
end
