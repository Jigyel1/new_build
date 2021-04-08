Devise::Mapping.instance_eval do
  def find_scope!(obj)
    obj = obj.devise_scope if obj.respond_to?(:devise_scope)
    case obj
    when String, Symbol
      return obj.to_sym
    when Class
      Devise.mappings.each_value { |m| return m.name if obj <= m.to }
    else
      # overriding the default devise implementation as this was causing the issue
      # of class `Telco::Uam::User` from `m.to`
      # not returning true for `obj.is_a?(m.to)`
      # although `obj.class` is also `Telco::Uam::User`
      Devise.mappings.each_value { |m| return m.name if obj.class.to_s == m.to.to_s }
    end

    raise "Could not find a valid mapping for #{obj.inspect}"
  end
end
