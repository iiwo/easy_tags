  module EasyTags
    ##
    # Handles injecting of the dynamic context related methods
    # Example:
    #   easy_tags_on :bees
    #
    #   # will create:
    #
    #   has_many :bees_taggings
    #   has_many :bees_tags
    #   def bees
    #   def bees=
    #   def bees_list
    #   def bees_list=
    class TaggableContextMethods
      class << self
        def inject(class_instance:, context:)
          class_instance.class_eval <<-METHODS, __FILE__ , __LINE__ + 1
            has_many(
              :#{context}_taggings, -> { includes(:tag).where(context: :#{context}) },
              as: :taggable,
              class_name: 'EasyTags::Tagging',
              dependent: :destroy,
              after_add: :after_tagging_change,
              after_remove: :after_tagging_change
            )
  
            has_many(
              :#{context}_tags,
              class_name: 'EasyTags::Tag',
              through: :#{context}_taggings,
              source: :tag
            )

            attribute :#{context}_list, ActiveModel::Type::Value.new          
            
            def #{context}
              EasyTags.configuration.parser.parse(#{context}_list)
            end

            def #{context}=(value)
             @#{context}_list = EasyTags.configuration.generator.generate(value)
             #{context}
            end
            
            def #{context}_list
              @#{context}_list ||= _persisted_#{context}_list
            end

            def #{context}_list=(value)
              parsed_value = EasyTags.configuration.parser.parse(value)
              regenerated_value = EasyTags.configuration.generator.generate(parsed_value)

              if regenerated_value != @#{context}_list
                set_attribute_was('#{context}_list', _persisted_#{context}_list)
                write_attribute('#{context}_list', regenerated_value)
                @#{context}_list = regenerated_value
                attribute_will_change!(:#{context}_list)
              end

              if regenerated_value == _persisted_#{context}_list
                clear_attribute_changes(:#{context}_list)
              end 
            end

            def _persisted_#{context}_list
              EasyTags.configuration.generator.generate(#{context}_tags.to_a(&:to_s))
            end

            def _persisted_#{context}
              EasyTags.configuration.parser.parse(_persisted_#{context}_list)
            end

            def _refresh_#{context}
              @#{context}_list = nil
              @#{context} = nil
            end
          METHODS
        end
      end
    end
  end