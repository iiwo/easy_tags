# frozen_string_literal: true

require 'rails/generators/active_record'

module EasyTags
  module Generators
    # generates database migration
    #
    # Usage
    #   rails g easy_tags:migration
    #
    class MigrationGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      def copy_migrations
        migration_template(
          'create_tables_migration.rb.erb',
          "#{db_migrate_path}/easy_tags_create_tables.rb",
          migration_version: migration_version
        )
      end

      private

        def migration_version
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        end
    end
  end
end
