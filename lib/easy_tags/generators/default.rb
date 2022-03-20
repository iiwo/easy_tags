# frozen_string_literal: true

module EasyTags
  module Generators
    # Default generator for [Array] -> [String] conversion
    class Default
      class << self
        # Generates a new String using the given Array
        #
        # @param [Array] tag_list
        # @return [String]
        #
        # Example:
        #   EasyTags::Generators::Default.generate(['One', 'Two', 'Three'])
        #   'One, Two, Three'
        def generate(tag_list)
          tag_list ||= []

          return '' if tag_list.empty?

          tag_list.join(',')
        end
      end
    end
  end
end
