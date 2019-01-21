module EasyTags
  module Generators
    ##
    # Generates a new String using the given TagList
    #
    # Example:
    #   EasyTags::TagList.generate(['One', 'Two', 'Three'])
    #   'One, Two, Three'
    class Default
      class << self
        def generate(tag_list)
          tag_list ||= []

          return '' if tag_list.empty?

          tag_list.join(',')
        end
      end
    end
  end
end
