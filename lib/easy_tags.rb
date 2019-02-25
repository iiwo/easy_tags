require 'active_support/dependencies/autoload'
require 'active_record'

module EasyTags
  extend ActiveSupport::Autoload

  autoload :Tag, 'easy_tags/tag'
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
    autoload :Item, 'easy_tags/options/item'
    autoload :List, 'easy_tags/options/list'
  end

  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def setup
      yield(configuration)
    end
  end

  class Configuration
    attr_accessor(
      :tags_table,
      :taggings_table,
      :parser,
      :generator
    )

    def initialize
      @tags_table = :tags
      @taggings_table = :taggings
      @parser = Parsers::Default
      @generator = Generators::Default
    end
  end
end
