module EasyTags
  # Handles tag context manipulation
  class TaggableContext
    # @param [String, Symbol] context
    # @param [Proc] refresh_persisted_tags
    # @param [Proc] on_change
    def initialize(context:, refresh_persisted_tags:, on_change:)
      self.context = context
      self.refresh_persisted_tags = refresh_persisted_tags
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
      @persisted_tags ||= TagList.new(refresh_persisted_tags.call)
    end

    # @param [String, Symbol] value
    # @return [TagList]
    def update(value)
      @tags = TagList.new(value)

      on_change.call(self) if changed?
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

    private

      attr_accessor :context, :refresh_persisted_tags, :on_change
  end
end
