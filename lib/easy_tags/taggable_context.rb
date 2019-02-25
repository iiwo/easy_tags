module EasyTags
  class TaggableContext
    def initialize(context:, refresh_persisted_tags:, on_change:)
      self.context = context
      self.refresh_persisted_tags = refresh_persisted_tags
      self.on_change = on_change
    end

    def changed?
      tags.sort != persisted_tags.sort
    end

    def tags
      @tags ||= TagList.new(persisted_tags)
    end

    def persisted_tags
      @persisted_tags ||= TagList.new(refresh_persisted_tags.call)
    end

    def update(value)
      @tags = TagList.new(value)

      on_change.call(self) if changed?
    end

    def new_tags
      tags - persisted_tags
    end

    def removed_tags
      persisted_tags - tags
    end

    def refresh
      @tags = nil
      @persisted_tags = nil
    end

    private

      attr_accessor :context, :refresh_persisted_tags, :on_change
  end
end