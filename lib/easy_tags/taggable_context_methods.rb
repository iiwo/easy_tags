# frozen_string_literal: true

module EasyTags
  # Handles injecting of the dynamic context related methods
  # Example:
  #   easy_tags_on :bees
  #
  #   # will create:
  #
  #   has_many :bees_taggings
  #   has_many :bees_tags
  #
  #   def bees
  #   def bees=
  #   def bees_list
  #   def bees_list=
  class TaggableContextMethods
    class << self
      def inject(class_instance:, context:)
        class_instance.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          has_many(
            :#{context}_taggings, -> { includes(:tag).where(context: :#{context}) },
            as: :taggable,
            class_name: 'EasyTags::Tagging',
            dependent: :destroy
          )

          has_many(
            :#{context}_tags,
            class_name: 'EasyTags::Tag',
            through: :#{context}_taggings,
            source: :tag
          )

          attribute :#{context}_list, ActiveModel::Type::Value.new

          def #{context}
            _taggable_context(:#{context})
          end

          def #{context}=(value)
            _taggable_context(:#{context}).update(value)
            #{context}
          end

          def #{context}_list
            _taggable_context(:#{context}).tags.to_s
          end

          def #{context}_list=(value)
            _taggable_context(:#{context}).update(value)
            #{context}_list
          end

          def #{context}_list_persisted
            _taggable_context(:#{context}).persisted_tags.to_s
          end
        RUBY
      end
    end
  end
end
