# frozen_string_literal: true

module TimeFormatter
  [ActiveSupport::TimeWithZone, Date].each do |klass|
    refine klass do
      def date_str
        in_time_zone('%d %B %Y')
      end

      def time_str
        in_time_zone('%H:%M:%S')
      end

      def datetime_str
        in_time_zone('%d %B %Y at %H:%M:%S')
      end

      def in_time_zone(format)
        super(Current.time_zone).strftime(format)
      end
    end
  end
end
