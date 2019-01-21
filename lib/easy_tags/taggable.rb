module EasyTags
  module Taggable
    class TagOption
      def initialize(option)
        @option = option
      end

      def valid?
        /[@$"]/ !~ filter.inspect
      end

      def filter
        @_filter ||= @option.to_sym
      end
    end

    class TagOptions
      def initialize(options)
        @options = options
      end

      def valid?
        filtered_options.all? { |option| option.valid? }
      end

      def filter
        filtered_options.map(&:filter)
      end

      private

        def filtered_options
          @_filtered_options ||= @options.to_a.flatten.compact.map do |raw_option|
            TagOption.new(raw_option)
          end
        end
    end

    module ClassMethods
      cattr_accessor :tagging_contexts

      def easy_tags_on(*tagging_contexts)
        self.tagging_contexts ||= []

        options = TagOptions.new(tagging_contexts.to_a)
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

        after_save :update_taggings
        after_find :refresh_tagging

        private

          def _tags_for(context:)
            public_send("#{context}".to_sym)
          end

          def _persisted_tags_for(context:)
            public_send("_persisted_#{context}".to_sym)
          end
      end

      private

        def update_taggings
          self.class.tagging_contexts.each do |context|
            tags = _tags_for(context: context)
            persisted_tags = _persisted_tags_for(context: context)

            next if tags == persisted_tags
            new_tags = tags - persisted_tags
            removed_tags = persisted_tags - tags

            new_tags.each do |tag_name|
              tag = Tag.find_or_create_by(name: tag_name)
              taggings.create(context: context, tag: tag)
            end

            taggings.joins(:tag).where(context: context).where(Tag.table_name => { name: removed_tags }).destroy_all
          end
        end

        def refresh_tagging
          self.class.tagging_contexts.each do |context|
            public_send("_refresh_#{context}".to_sym)
          end
        end

        def reload
          refresh_tagging
          super
        end
    end
  end
end
