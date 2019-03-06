module EasyTags
  # Taggable instance methods
  module TaggableMethods
    class << self
      def inject(class_instance:)
        class_instance.class_eval do
          has_many :taggings, as: :taggable, dependent: :destroy, class_name: '::EasyTags::Tagging'
          has_many :base_tags, through: :taggings, source: :tag, class_name: '::EasyTags::Tag'

          after_save :_update_taggings, :_refresh_tagging
          after_find :_refresh_tagging

          def reload
            _refresh_tagging
            super
          end

          private

          attr_accessor :_taggable_contexts

          def _taggable_contexts
            @_taggable_contexts ||= {}
          end

          def _update_taggings
            self.class.tagging_contexts.each do |context|
              context_tags = _taggable_context(context)

              next unless context_tags.changed?

              context_tags.new_tags.each do |tag_name|
                tag = Tag.find_or_create_by!(name: tag_name)
                taggings.create!(context: context, tag: tag)
              end

              taggings
                .joins(:tag)
                .where(context: context)
                .where(Tag.table_name => { name: context_tags.removed_tags })
                .destroy_all
            end
          end

          def _refresh_tagging
            self.class.tagging_contexts.each do |context|
              _taggable_context(context).refresh
            end
          end

          def _mark_dirty(context:, taggable_context:)
            write_attribute("#{context}_list", taggable_context.tags)
            set_attribute_was("#{context}_list", taggable_context.persisted_tags)
            attribute_will_change!("#{context}_list")
          end

          def _taggable_context(context)
            _taggable_contexts[context] ||= TaggableContext.new(
              context: context,
              refresh_persisted_tags: -> {
                taggings.joins(:tag).where(context: context).pluck(:name)
              },
              on_change: -> (tag_context) {
                _mark_dirty(context: context, taggable_context: tag_context)
              }
            )
          end
        end
      end
    end
  end
end