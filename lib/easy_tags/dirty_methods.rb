# frozen_string_literal: true

module EasyTags
  # Handles dirty behaviour
  module DirtyMethods
    RAILS_6 = ::ActiveRecord.gem_version >= ::Gem::Version.new('6.0.0')

    def _mark_dirty(context:, taggable_context:)
      _set_dirty_previous_value(attribute_name: "#{context}_list", value: taggable_context.persisted_tags.to_s)
      write_attribute("#{context}_list", taggable_context.tags.to_s)
      attribute_will_change!("#{context}_list")
    end

    if RAILS_6
      def _set_dirty_previous_value(attribute_name:, value:)
        @attributes[attribute_name] = ActiveModel::Attribute.from_user(
          attribute_name,
          value,
          ActiveModel::Type::Value.new
        )
      end
    else
      def _set_dirty_previous_value(attribute_name:, value:)
        set_attribute_was(attribute_name, value)
      end
    end
  end
end
