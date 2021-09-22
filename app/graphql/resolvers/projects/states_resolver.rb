# frozen_string_literal: true

module Resolvers
  module Projects
    class StatesResolver < SearchObjectBase
      scope do
        states = ::Projects::StateMachine.aasm.states.map(&:name)
        Hash[(0...states.size).zip(states)]
      end

      type GraphQL::Types::JSON, null: false
    end
  end
end
