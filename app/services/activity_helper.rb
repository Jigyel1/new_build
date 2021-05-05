module ActivityHelper
  def activity
    @activity ||= attributes[:activity]
  end

  def parameters
    @parameters ||= RecursiveOpenStruct.new(activity.parameters)
  end
end
