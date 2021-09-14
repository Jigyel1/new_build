module Projects
  module Transitions
    module Callbacks
      def after_technical_analysis_completed
        byebug
        project.update!(attributes)
      end
    end
  end
end
