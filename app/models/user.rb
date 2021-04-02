# Aliasing Class Telco::Uam::User to User so that you can use
#   => User.create!, User.new
#      or any other class method
# without the need to explicitly add the namespace everytime.
#
# User = Telco::Uam::User
#
# Telco::Uam::User.class_eval do
#   def self.current_table_name
#     byebug
#   end
#
#   def active_for_authentication?
#     false
#   end
# end
#
# module Telco::Uam::User
#   module ClassMethods
#     def active_for_authentication?
#       false
#     end
#   end
#
#   def active_for_authentication?
#     falses
#   end
# end