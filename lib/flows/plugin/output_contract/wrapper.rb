module Flows
  module Plugin
    module OutputContract
      # Contains wrappers for initializer and `#call` methods.
      #
      # @api private
      module Wrapper
        def initialize(*args, &block)
          super(*args, &block)
          klass = self.class
          raise NoContractError, klass if klass.success_contracts.empty?
        end

        def call(*args, &block)
          result = super(*args, &block)
          klass = self.class

          contract = Util.contract_for(klass, result)

          Util.transform_result(klass, contract, result)

          result
        end

        # Helper methods for {Wrapper} are extracted to this
        # module as singleton methods to not pollute user classes.
        #
        # @api private
        module Util
          class << self
            def contract_for(klass, result)
              raise ResultTypeError.new(klass, result) unless result.is_a?(Flows::Result)

              status = result.status
              contracts = result.ok? ? klass.success_contracts : klass.failure_contracts

              contracts[status] || raise(StatusError.new(klass, result, contracts.keys))
            end

            def transform_result(klass, contract, result)
              data = result.send(:data)

              transformed_result = contract.transform(data)
              raise ContractError.new(klass, result, transformed_result.error) if transformed_result.err?

              result.send(:'data=', transformed_result.unwrap)
            end
          end
        end
      end
    end
  end
end
