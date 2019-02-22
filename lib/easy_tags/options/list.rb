module EasyTags
  module Options
    class List
      def initialize(options)
        @options = options
      end

      def valid?
        filtered_options.all? { |option| option.valid? }
      end

      def filter
        filtered_options.map(&:filter)
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