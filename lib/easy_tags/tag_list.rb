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