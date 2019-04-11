module EasyTags
  module Options
    # Represents a single option item
    class Item
      def initialize(option)
        @option = option
      end

      # @return [Boolean]
      def valid?
        /[@$"]/ !~ name.inspect
      end

      # @return [Symbol]
      def name
        @name ||= key.to_sym
      end

      # @return [Array<Callback>]
      def callbacks
        return [] unless callbacks?

        @option.values.first.map do |type, callback|
          Callback.new(callback: callback, type: type)
        end
      end

      private

        def key
          return @option.keys.first if callbacks?

          @option
        end

        def callbacks?
          @option.is_a?(Hash)
        end
    end
  end
end
