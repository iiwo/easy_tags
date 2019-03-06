module EasyTags
  module Options
    # Represents a single option item
    class Item
      def initialize(option)
        @option = option
      end

      # @return [Boolean]
      def valid?
        /[@$"]/ !~ filter.inspect
      end

      # @return [Symbol]
      def filter
        @_filter ||= @option.to_sym
      end
    end
  end
end
