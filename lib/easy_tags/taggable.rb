module EasyTags
  module Taggable
    module ClassMethods
      cattr_accessor :tagging_contexts

      def easy_tags_on(*tagging_contexts)
        self.tagging_contexts ||= []

        options = Options::List.new(tagging_contexts.to_a)
        raise 'invalid options' unless options.valid?

        self.tagging_contexts += options.filter
        self.tagging_contexts.uniq!

        self.tagging_contexts.each do |context|
          EasyTags::TaggableContextMethods.inject(
            class_instance: self,
            context: context
          )
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        has_many :taggings, as: :taggable, dependent: :destroy, class_name: '::EasyTags::Tagging'
        has_many :base_tags, through: :taggings, source: :tag, class_name: '::EasyTags::Tag'

        after_save :update_taggings, :refresh_tagging
        after_find :refresh_tagging

        def reload
          refresh_tagging
          super
        end

        private

          # @param context [String/Symbol]
          # @return [TagList] currently instance(unpersisted) assigned tags
          def _tags_for(context:)
            list = instance_variable_get("@#{context}_list")
            return list unless list.nil?

            instance_variable_set(
              "@#{context}_list",
              TagList.new(_persisted_tags_for(context: context))
            )
          end

          # @param context [String/Symbol]
          # @return [TagList] currently instance(persisted) assigned tags
          def _persisted_tags_for(context:)
            list = instance_variable_get("@persisted_#{context}_list")
            return list unless list.nil?

            instance_variable_set(
              "@persisted_#{context}_list",
              TagList.new(taggings.joins(:tag).where(context: context).pluck(:name))
            )
          end

          def _tags_list_for(context:)
            _tags_for(context: context).to_s
          end

          def _persisted_tags_list_for(context:)
            _persisted_tags_for(context: context).to_s
          end

          def _tags_list_update(context:, value:)
            persisted_tags = _persisted_tags_for(context: context)

            instance_variable_set(
              "@#{context}_list",
              TagList.new(value)
            )
            tags = _tags_for(context: context)

            if tags.sort != persisted_tags.sort
              write_attribute("#{context}_list", tags)
              set_attribute_was("#{context}_list", persisted_tags)
              attribute_will_change!("#{context}_list")
            end
          end


          def update_taggings
            self.class.tagging_contexts.each do |context|
              persisted_tags = _persisted_tags_for(context: context)
              tags = _tags_for(context: context)

              next if tags == persisted_tags

              new_tags = tags - persisted_tags
              removed_tags = persisted_tags - tags

              new_tags.each do |tag_name|
                tag = Tag.find_or_create_by!(name: tag_name)
                taggings.create!(context: context, tag: tag)
              end

              taggings.joins(:tag).where(context: context).where(Tag.table_name => { name: removed_tags }).destroy_all
            end
          end

          def refresh_tagging
            self.class.tagging_contexts.each do |context|
              instance_variable_set("@#{context}_list", nil)
              instance_variable_set("@persisted_#{context}_list", nil)
            end
          end
      end
    end
  end
end
