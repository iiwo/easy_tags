module EasyTags
  module Parsers
    class Default
      class << self
        ##
        # Returns a new TagList using the given tag string.
        #
        # Example:
        #   EasyTags::Parsers::Default.parse('One , Two,  Three')
        #   ['One', 'Two', 'Three']
        def parse(tag_list_string)
          return TagList.new if tag_list_string.to_s.empty?

          tag_list_string.split(/,/).map(&:strip)
        end
      end
    end
  end
end
