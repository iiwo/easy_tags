module EasyTags
  class TagList < Array
    def initialize(
        *args,
        generator: EasyTags.configuration.generator,
        parser: EasyTags.configuration.parser
    )
      self.generator = generator
      self.parser = parser
      add(*args)
    end

    ##
    # Add tags to the tag_list. Duplicate or blank tags will be ignored.
    #
    # Example:
    #   tag_list.add('Fun', 'Happy')
    def add(*names)
      filter(names).each { |filtered_name| push(filtered_name) }
    end

    # Append---Add the tag to the tag_list. This
    # expression returns the tag_list itself, so several appends
    # may be chained together.
    def <<(obj)
      add(obj)
    end

    # Concatenation --- Returns a new tag list built by concatenating the
    # two tag lists together to produce a third tag list.
    def +(other_tag_list)
      TagList.new.add(self).add(other_tag_list)
    end

    # Appends the elements of +other_tag_list+ to +self+.
    def concat(other_tag_list)
      super(other_tag_list).uniq
    end

    ##
    # Remove specific tags from the tag_list
    #
    # Example:
    #   tag_list.remove('Sad', 'Lonely')
    def remove(*names)
      super(names)
    end

    ##
    # Transform the tag_list into a tag string
    def to_s
      generator.generate(self)
    end

    private

      attr_accessor :generator, :parser

      def filter(names)
        names.map{ |name| parser.filter(name) }.uniq
      end
  end
end