module EasyTags
  module Options
    # Represents a single callback item
    class Callback
      attr_reader :context

      TYPES = %i[after_add after_remove].freeze

      # @param [Proc] callback
      # @param [Symbol] type
      def initialize(callback:, type:)
        @callback = callback
        @type = type

        raise "unknown callback type - must be one of #{TYPES}" unless TYPES.include?(type)
      end

      # @return [String]
      attr_reader :type

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
