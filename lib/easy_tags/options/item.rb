module EasyTags
  module Options
    class Item
      def initialize(option)
        @option = option
      end

      def valid?
        /[@$"]/ !~ filter.inspect
      end

      def filter
        @_filter ||= @option.to_sym
      end
    end
  end
end
