module EasyTags
  module Taggable
    module ClassMethods
      cattr_accessor :tagging_contexts do
        []
      end

      def easy_tags_on(*tagging_contexts_params)
        options = Options::Collection.new(tagging_contexts_params.to_a)
        raise 'invalid options' unless options.valid?

        tagging_contexts.push(*options.filter)
        tagging_contexts.uniq!

        tagging_contexts.each do |context|
          EasyTags::TaggableContextMethods.inject(
            class_instance: self,
            context: context
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
