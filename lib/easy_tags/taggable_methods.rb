# frozen_string_literal: true

module EasyTags
  # Taggable instance methods
  module TaggableMethods
    class << self
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def inject(class_instance:)
        # rubocop:disable Metrics/BlockLength
        class_instance.class_eval do
          has_many(
            :taggings,
            as: :taggable,
            dependent: :destroy,
            class_name: '::EasyTags::Tagging',
            inverse_of: :taggable
          )

          after_save :_update_taggings, :_refresh_tagging
          after_find :_refresh_tagging

          # override ActiveRecord::Persistence#reload
          # to refresh tags each time the model instance gets reloaded
          def reload(*args)
            _refresh_tagging
            super
          end

          private

          attr_accessor :_taggable_contexts

          def _taggable_contexts
            @_taggable_contexts ||= {}
          end

          def _update_taggings
            tagging_contexts.each do |context|
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
            tagging_contexts.each do |context|
              _taggable_context(context).refresh
            end
          end

          include DirtyMethods

          def _taggable_context(context)
            _taggable_contexts[context] ||= TaggableContext.new(
              context: context,
              tags_association: public_send("#{context}_tags"),
              on_change: lambda { |tag_context|
                _mark_dirty(context: context, taggable_context: tag_context)
              }
            )
          end

          def _notify_tag_change(type:, tagging:)
            callbacks_for_type = tagging_callbacks[tagging.context.to_sym].select do |callback|
              callback.type == type
            end

            callbacks_for_type.each do |callback|
              callback.run(taggable: self, tagging: tagging)
            end
          end

          def _notify_tag_add(tagging)
            _notify_tag_change(type: :after_add, tagging: tagging)
          end

          def _notify_tag_remove(tagging)
            _notify_tag_change(type: :after_remove, tagging: tagging)
          end
        end
        # rubocop:enable Metrics/BlockLength
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
