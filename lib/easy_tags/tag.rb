module EasyTags
  # Tag model
  class Tag < ::ActiveRecord::Base
    self.table_name = EasyTags.tags_table

    has_many :taggings, dependent: :destroy, class_name: '::EasyTags::Tagging', inverse_of: :tag

    validates_presence_of :name
    validates_uniqueness_of :name
    validates_length_of :name, maximum: 255

    after_commit :notify_add, on: :create
    after_commit :notify_remove, on: :destroy

    def to_s
      name
    end

    private

      def notify_add
        ActiveSupport::Notifications.instrument(
          'easy_tag.tag_added',
          tag: self
        )
      end

      def notify_remove
        ActiveSupport::Notifications.instrument(
          'easy_tag.tag_removed',
          tag: self
        )
      end
  end
end
