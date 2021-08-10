# frozen_string_literal: true

module Projects
  class TransformAddressBook
    attr_reader :type

    def initialize(type)
      @type = type.to_s
    end

    # to_int of external_id, zip etc
    def process(project)
      "Projects::#{type.camelize}Populator".constantize.new(project, type: type).call
    end
  end
end
