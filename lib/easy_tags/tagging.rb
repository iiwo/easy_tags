module EasyTags
  # Tagging model
  class Tagging < ::ActiveRecord::Base
    self.table_name = EasyTags.taggings_table

    belongs_to :tag, class_name: '::EasyTags::Tag', optional: false, inverse_of: :taggings
    belongs_to :taggable, polymorphic: true, optional: false, inverse_of: :taggings

    validates_uniqueness_of :tag_id, scope: %i[taggable_type taggable_id context]

    after_commit :notify_add, on: :create
    after_commit :notify_remove, on: :destroy

    private

      def notify_add
        ActiveSupport::Notifications.instrument(
          "easy_tag.tagging_added.#{taggable_type.to_s.tableize}.#{context}",
          tagging: self
        )

        taggable.send(:_notify_tag_add, self)
      end

      def notify_remove
        ActiveSupport::Notifications.instrument(
          "easy_tag.tagging_added#{taggable_type.to_s.tableize}.#{context}",
          tagging: self
        )

        taggable.send(:_notify_tag_remove, self)
      end
  end
end
