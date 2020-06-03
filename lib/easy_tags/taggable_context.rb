module EasyTags
  # Handles tag context manipulation
  class TaggableContext
    # @param [String, Symbol] context
    # @param [ActiveRecord::Relation] tags_association
    # @param [Proc] on_change
    def initialize(context:, tags_association:, on_change:)
      self.context = context
      self.tags_association = tags_association
      self.on_change = on_change
    end

    # @return [true, false]
    def changed?
      tags.sort != persisted_tags.sort
    end

    # @return [TagList]
    def tags
      @tags ||= TagList.new(persisted_tags)
    end

    # @return [TagList]
    def persisted_tags
      @persisted_tags ||= preloaded_persisted_tags
    end

    # @param [String, Symbol] value
    # @return [TagList]
    def update(value)
      @tags = TagList.new(value)

      notify_change
    end

    # @return [TagList]
    def new_tags
      tags - persisted_tags
    end

    # @return [TagList]
    def removed_tags
      persisted_tags - tags
    end

    # clear memoized info and force a refresh
    def refresh
      @tags = nil
      @persisted_tags = nil
    end

    # Add tags to the tag_list. Duplicate or blank tags will be ignored.
    #
    # Example:
    #   tag_list.add('Fun', 'Happy')
    def add(*names)
      tags.add(*names).tap do
        notify_change
      end
    end

    # Remove item from list
    #
    # Example:
    #   tag_list.remove('Issues')
    def remove(value)
      tags.remove(value).tap do
        notify_change
      end
    end

    delegate :==, :<=>, :to_s, :inspect, :hash, to: :tags

    private

      attr_accessor :context, :tags_association, :on_change

      def respond_to_missing?(name, _include_private = false)
        tags.respond_to?(name)
      end

      def method_missing(name, *args, &block)
        return super unless respond_to_missing?(name)

        tags.send(name, *args, &block)
      end

      def notify_change
        on_change.call(self) if changed?
      end

      def preloaded_persisted_tags
        return TagList.new(tags_association.reload.map(&:name)) if @preloaded

        @preloaded = true
        TagList.new(tags_association.map(&:name))
      end
  end
end
