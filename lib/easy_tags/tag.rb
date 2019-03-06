module EasyTags
  # Tag model
  class Tag < ::ActiveRecord::Base
    self.table_name = EasyTags.tags_table

    has_many :taggings, dependent: :destroy, class_name: '::EasyTags::Tagging'

    validates_presence_of :name
    validates_uniqueness_of :name
    validates_length_of :name, maximum: 255

    def to_s
      name
    end
  end
end
