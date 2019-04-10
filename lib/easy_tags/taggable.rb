module EasyTags
  module Taggable
    module ClassMethods
      # Examples
      #
      #   easy_tags_on :highlights
      #
      # with multiple contexts:
      #
      #   easy_tags_on :highlights, :tags
      #
      # with callbacks:
      #
      #   easy_tags_on(
      #     highlights: { after_add: :add_tag_callback, after_remove: -> (tagging) { puts "removed #{tagging.tag.name}" } }
      #   )
      #
      def easy_tags_on(*tagging_contexts_params)
        cattr_accessor :tagging_contexts
        cattr_accessor :tagging_callbacks

        options = Options::Collection.new(tagging_contexts_params.to_a)
        raise 'invalid options' unless options.valid?

        self.tagging_contexts ||= []
        self.tagging_callbacks ||= {}

        options.items.each do |option|
          tagging_contexts.push(option.name) unless tagging_contexts.include?(option.name)
          tagging_callbacks[option.name] = option.callbacks

          EasyTags::TaggableContextMethods.inject(
            class_instance: self,
            context: option.name
          )
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      EasyTags::TaggableMethods.inject(class_instance: base)
    end
  end
end
