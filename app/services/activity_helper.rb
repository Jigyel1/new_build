# frozen_string_literal: true

module ActivityHelper
  def activity
    @activity ||= attributes[:activity]
  end

  def parameters
    @parameters ||= RecursiveOpenStruct.new(activity.parameters)
  end

  def log_data
    @log_data ||= RecursiveOpenStruct.new(activity.log_data)
  end
end
