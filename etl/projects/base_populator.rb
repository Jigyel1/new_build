module Projects
  class BasePopulator
    include Helper
    attr_reader :project, :type

    def initialize(project, type: nil)
      @project = project
      @type = type
    end

    def call
      yield if execute?

      project
    end
  end
end
