require_relative 'operation/errors'

require_relative 'operation/dsl'
require_relative 'operation/builder'
require_relative 'operation/executor'

module Flows
  # Operaion DSL
  module Operation
    def self.included(mod)
      mod.instance_variable_set(:@steps, [])
      mod.extend ::Flows::Operation::DSL
    end

    include ::Flows::Result::Helpers

    def initialize
      _flows_do_checks

      @_flows_flow = ::Flows::Operation::Builder.new(
        steps: self.class.steps,
        method_source: self
      ).call

      @_flows_executor = ::Flows::Operation::Executor.new(
        flow: @_flows_flow,
        success_shapes: self.class.success_shapes,
        failure_shapes: self.class.failure_shapes
      )
    end

    def call(**params)
      @_flows_executor.call(**params)
    end

    private

    def _flows_do_checks
      raise NoStepsError if self.class.steps.empty?
      raise NoSuccessShapeError if self.class.success_shapes.nil?
    end
  end
end