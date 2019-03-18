module EasyTags
  module Options
    # Represents collection of options
    class Collection
      def initialize(options)
        @options = options
      end

      # @return [Boolean]
      def valid?
        filtered_options.all? { |option| option.valid? }
      end

      # @return [String]
      def items
        filtered_options
      end

      private

        def filtered_options
          @_filtered_options ||= @options.to_a.flatten.compact.map do |raw_option|
            Item.new(raw_option)
          end
        end
    end
  end
end