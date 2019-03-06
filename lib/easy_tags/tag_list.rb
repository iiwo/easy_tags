module EasyTags
  # Represents a tag list
  class TagList < SimpleDelegator
    def initialize(
        *args,
        generator: EasyTags.generator,
        parser: EasyTags.parser
    )
      self.generator = generator
      self.parser = parser
      super([])

      add(*args)
    end

    # Add tags to the tag_list. Duplicate or blank tags will be ignored.
    #
    # Example:
    #   tag_list.add('Fun', 'Happy')
    def add(*names)
      filter(names).each { |filtered_name| push(filtered_name) unless include?(filtered_name) }
    end

    ##
    # Transform the tag_list into a tag string
    def to_s
      generator.generate(self)
    end

    private

      attr_accessor :generator, :parser

      def filter(names)
        names.to_a.flatten.compact.map do |name|
          parser.parse(name)
        end.flatten.compact.uniq
      end
  end
end