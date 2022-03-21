# frozen_string_literal: true

module EasyTags
  module Options
    # Represents collection of options
    class Collection
      def initialize(options)
        @options = options.uniq
      end

      # @return [Boolean]
      def valid?
        filtered_options.all?(&:valid?)
      end

      # @return [String]
      def items
        filtered_options
      end

      private

        def filtered_options
          @filtered_options ||= @options.to_a.flatten.compact.map do |raw_option|
            Item.new(raw_option)
          end
        end
    end
  end
end
