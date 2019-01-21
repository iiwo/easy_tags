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

          TagList.new(*tag_list_string.split(/,/))
        end

        ##
        # Filters a tag name string
        #
        # Example:
        #   EasyTags::Parsers::Default.filter(' One')
        #   'One'
        #
        #   EasyTags::Parsers::Default.filter('    ')
        #   nil
        def filter(name)
          return nil if name.to_s.empty?
          name.to_s.strip
        end
      end
    end
  end
end
