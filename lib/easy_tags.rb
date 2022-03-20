# frozen_string_literal: true

require 'active_support/dependencies/autoload'
require 'active_record'

# rubocop:disable Style/Documentation
module EasyTags
  extend ActiveSupport::Autoload

  autoload :DirtyMethods, 'easy_tags/dirty_methods'
  autoload :Tag, 'easy_tags/tag'
  autoload :TaggableMethods, 'easy_tags/taggable_methods'
  autoload :TaggableContextMethods, 'easy_tags/taggable_context_methods'
  autoload :TaggableContext, 'easy_tags/taggable_context'
  autoload :Taggable, 'easy_tags/taggable'
  autoload :Tagging, 'easy_tags/tagging'
  autoload :TagList, 'easy_tags/tag_list'
  autoload :VERSION, 'easy_tags/version'

  module Parsers
    autoload :Default, 'easy_tags/parsers/default'
  end

  module Generators
    autoload :Default, 'easy_tags/generators/default'
  end

  module Options
    autoload :Callback, 'easy_tags/options/callback'
    autoload :Item, 'easy_tags/options/item'
    autoload :Collection, 'easy_tags/options/collection'
  end
  # rubocop:enable Style/Documentation

  # handle lib configuration options
  #
  # Example
  #
  #  EasyTags.setup do |config|
  #    config.tags_table = :tags
  #    config.taggings_table = :taggings
  #    config.parser = EasyTags::Parsers::Default
  #    config.generator = EasyTags::Generators::Default
  #  end
  #
  class Configuration
    OPTIONS = %i[
      tags_table
      taggings_table
      parser
      generator
    ].freeze

    attr_accessor(
      *OPTIONS
    )

    def initialize
      self.tags_table = :tags
      self.taggings_table = :taggings
      self.parser = Parsers::Default
      self.generator = Generators::Default
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def setup
      yield(configuration)
    end

    delegate(*Configuration::OPTIONS, to: :configuration)
  end
end
