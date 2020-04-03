module Flows
  class Type
    # Type checker for wrapping block checker with error message.
    #
    # @example
    #     positive_check = Flows::Type::Predicate.new 'must be positive' do |x|
    #       x > 0
    #     end
    #
    #     positive_check === 10
    #     # => true
    #
    #     positive_check === -100
    #     # => false
    class Predicate < Type
      def initialize(error_message, &block)
        @error_message = error_message
        @block = block
      end

      private

      def do_check(other)
        if @block === other
          true
        else
          @error_message
        end
      end
    end
  end
end