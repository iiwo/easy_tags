module EasyTags
  module Parsers
    # Default parser for [String] -> [Array] conversion
    class Default
      class << self
        # Returns a new TagList using the given tag string.
        #
        # @param [String] tag_list_string
        # @return [Array<String>]
        #
        # Example:
        #   EasyTags::Parsers::Default.parse('One , Two,  Three')
        #   ['One', 'Two', 'Three']
        def parse(tag_list_string)
          return [] if tag_list_string.to_s.empty?

          tag_list_string.to_s.split(/,/).map(&:strip)
        end
      end
    end
  end
end
