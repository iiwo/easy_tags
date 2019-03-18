module EasyTags
  module Taggable
    module ClassMethods
      cattr_accessor :tagging_contexts do
        []
      end

      cattr_accessor :tagging_callbacks do
        {}
      end

      def easy_tags_on(*tagging_contexts_params)
        options = Options::Collection.new(tagging_contexts_params.to_a)
        raise 'invalid options' unless options.valid?

        options.items.each do |option|
          next if tagging_contexts.include?(option.name)

          tagging_contexts.push(option.name)
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
