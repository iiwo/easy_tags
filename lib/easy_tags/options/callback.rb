module EasyTags
  module Options
    # Represents a single callback item
    class Callback
      attr_reader :context

      TYPES = %i[after_add after_remove]

      # @param [Proc] callback
      # @param [Symbol] type
      def initialize(callback:, type:)
        @callback = callback
        @type = type

        unless TYPES.include?(type)
          raise "unknown callback type - must be one of #{TYPES}"
        end
      end

      # @return [String]
      def type
        @type
      end

      # invoke callback for a taggable object for a specific tagging
      #
      # @param [Object] taggable
      # @param [Object] tagging
      def run(taggable:, tagging:)
        if @callback.is_a?(Symbol)
          taggable.send(@callback, tagging)
        elsif @callback.is_a?(Proc)
          taggable.instance_exec tagging, &@callback
        end
      end
    end
  end
end
