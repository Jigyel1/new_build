# require 'devise/strategies/authenticatable'
#
# module Devise
#   module Strategies
#     class TelcoAuthenticatable < Authenticatable
#       def valid?
#         true
#       end
#
#       def authenticate!
#         super
#       end
#     end
#   end
# end
#
# Warden::Strategies.add(:telco_authenticatable, Devise::Strategies::TelcoAuthenticatable)