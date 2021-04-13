# frozen_string_literal: true

require 'pry'

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length of a method exceeds some maximum value.
      # This is customized for Selise Projects because rubocop checks are dumb sometimes
      # It does not understand the difference between params and methods
      class SeliseMethodLength < Cop
        include CodeLength

        LABEL = 'Method'
        ALLOWED_METHODS = [
          /\w+_params$/,
          /\w+_attributes$/,
          /\w+_variables$/,
          /\w+_search$/,
          /\w+_hash$/
        ].freeze

        def on_def(node)
          method_name = String(node.method_name)
          excluded_methods = cop_config['ExcludedMethods'] || []
          return if excluded_methods.include?(method_name)

          return if ALLOWED_METHODS.any? { |pattern| pattern.match?(method_name) }

          check_code_length(node)
        end
        alias on_defs on_def

        def on_block(node)
          return unless node.send_node.method_name == :define_method

          check_code_length(node)
        end

        def check_code_length(node)
          return if node.line_count <= max_length

          calculator = build_code_length_calculator(node)
          length = calculator.calculate
          return if length <= max_length

          add_offense(node, message: message(length, max_length)) do
            self.max = length
          end
        end

        private

        def cop_label
          LABEL
        end
      end
    end
  end
end
