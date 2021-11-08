# frozen_string_literal: true

module TimeFormatter
  [ActiveSupport::TimeWithZone, Date].each do |klass|
    refine klass do
      def time_str
        in_time_zone('%I:%M:%S %p')
      end

      def date_str
        in_time_zone('%d.%m.%Y')
      end

      def datetime_str
        in_time_zone('%d.%m.%Y %I:%M:%S %p')
      end

      def in_time_zone(format)
        super(Current.time_zone).strftime(format)
      end
    end
  end
end
