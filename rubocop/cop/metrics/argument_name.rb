# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      class ArgumentName < Cop
        def_node_matcher :argument_name, <<~PATTERN
          (send nil? :argument (:sym $_) ...)
        PATTERN

        MSG = 'Use snake_case for argument names'

        SNAKE_CASE = /^[\da-z_]+[!?=]?$/

        def on_send(node)
          argument_name(node) do |name|
            next if name.match?(SNAKE_CASE)

            add_offense(node)
          end
        end
      end
    end
  end
end
