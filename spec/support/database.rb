module Database
  def self.prepare
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table EasyTags.configuration.tags_table do |t|
        t.string :name, index: true

        t.timestamps null: false
      end

      create_table EasyTags.configuration.taggings_table do |t|
        t.references :tag, foreign_key: { to_table: EasyTags.configuration.tags_table }, null: false, index: true
        t.references :taggable, polymorphic: true, index: true, null: false
        t.string :context, null: false, index: true

        t.datetime :created_at, null: false
      end

      create_table :taggable_models do |t|
        t.timestamps null: false
      end
    end
  end
end

class TaggableModel < ActiveRecord::Base
  include EasyTags::Taggable
  easy_tags_on :highlights, :birds, :tags
  easy_tags_on :bees
end