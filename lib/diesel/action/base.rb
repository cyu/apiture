module Diesel
  module Action
    class Base

      def perform(context)
        raise NotImplementedError
      end

      def accept?(context)
        true
      end

    end
  end
end
