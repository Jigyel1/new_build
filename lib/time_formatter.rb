# frozen_string_literal: true

module TimeFormatter
  [ActiveSupport::TimeWithZone, Date].each do |klass|
    refine klass do
      def time_str
        in_time_zone('%H:%M:%S')
      end

      def date_str
        in_time_zone('%Y-%m-%d')
      end

      def in_time_zone(format)
        super(Current.time_zone).strftime(format)
      end
    end
  end
end
