module EasyTags
  class Tagging < ::ActiveRecord::Base
    self.table_name = EasyTags.configuration.taggings_table

    DEFAULT_CONTEXT = 'tags'.freeze

    belongs_to :tag, class_name: '::EasyTags::Tag'
    belongs_to :taggable, polymorphic: true

    scope :by_context, ->(context = DEFAULT_CONTEXT) { where(context: context) }

    validates_presence_of :context
    validates_presence_of :tag_id

    validates_uniqueness_of :tag_id, scope: %i[taggable_type taggable_id context]
  end
end
