[![Maintainability](https://qlty.sh/gh/iiwo/projects/easy_tags/maintainability.svg)](https://qlty.sh/gh/iiwo/projects/easy_tags)
[![CI Status](https://github.com/iiwo/easy_tags/workflows/CI/badge.svg?branch=master)](https://github.com/iiwo/easy_tags/actions?query=workflow%3ACI+branch%3Amaster)
[![Code Coverage](https://qlty.sh/gh/iiwo/projects/easy_tags/coverage.svg)](https://qlty.sh/gh/iiwo/projects/easy_tags)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [EasyTags](#easytags)
  - [Migrating from ActsAsTaggableOn](#migrating-from-actsastaggableon)
  - [Installation](#installation)
    - [Post Installation](#post-installation)
  - [Usage](#usage)
    - [Setup](#setup)
    - [Interface](#interface)
    - [Examples](#examples)
      - [Adding/Removing tags](#addingremoving-tags)
      - [Querying](#querying)
        - [Context relations](#context-relations)
        - [Global relations](#global-relations)
    - [Callbacks](#callbacks)
      - [Instance scope callbacks](#instance-scope-callbacks)
      - [Active Support Instrumentation custom notifications](#active-support-instrumentation-custom-notifications)
        - [Tag notifications](#tag-notifications)
        - [Tagging notifications](#tagging-notifications)
    - [Dirty objects](#dirty-objects)
  - [Configuration](#configuration)
  - [Testing](#testing)
  - [Development](#development)
  - [Contributing](#contributing)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# EasyTags

Easy contextual tagging for Rails

## Migrating from ActsAsTaggableOn

This gem was inspired by [ActsAsTaggableOn](https://github.com/mbleigh/acts-as-taggable-on).
It was built on similar model, but rewritten from scratch and simplified with better maintainability in mind.
Considerable amount of features has been removed and we've made some breaking changes.
Please refer to [ActsAsTaggableOn migration notes](https://github.com/iiwo/easy_tags/blob/master/MIGRATING_FROM_AATO.MD) if you want to migrate

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_tags'
```

And then execute:
```shell
$ bundle
```

### Post Installation

generate migration with:
```shell
rails g easy_tags:migration
```

## Usage

### Setup

in your ActiveRecord model add:

```ruby
include EasyTags::Taggable

easy_tags_on :highlights
```

with multiple tag contexts:
```ruby
include EasyTags::Taggable

easy_tags_on :highlights, :tags, :notes
```

### Interface
upon the `easy_tags_on` declaration:
```ruby
easy_tags_on :highlights
```

the following methods will be auto-generated and made available for your model instance (`highlights` being an example context name):

| description                        | method                           |
|------------------------------------|----------------------------------|
| set tags using string of tag names | `highlights_list=(value)`        |
| get string of tag names            | `highlights_list`                |
| get string of persisted tag names  | `highlights_list_persisted`      |
| set tags with array of tag names   | `highlights=(value)`             |
| get array of tag names             | `highlights`                     |

- the String accessor is helpful when working with client side tagging UI solutions such as ie. [select2](https://select2.org/tagging)
- the Array accessor gives you convenient array item manipulation

### Examples

#### Adding/Removing tags

Using Array accessor
```ruby
# assign/replace tags (comma separated using the default parser)
model.highlights = ['My Tag', 'Second Tag', 'Some Other tag']
# => [
#      [0] "My Tag",
#      [1] "Second Tag",
#      [2] "Some Other tag"
#  ]

# add tags
model.highlights.add('One More', 'And Another')
model.highlights
# => [
#     [0] "My Tag",
#     [1] "Second Tag",
#     [2] "Some Other tag",
#     [3] "One More",
#     [4] "And Another"
#  ]

# remove a single tag
model.highlights.remove('One More')
model.highlights
# => [
#     [0] "My Tag",
#     [1] "Second Tag",
#     [2] "Some Other tag",
#     [3] "And Another"
#  ]

# remember to persist changes
model.save
```

Using String accessor
```ruby
# add multiple tags (comma separated using the default parser)
model.highlights_list = 'My Tag, Second Tag, Some Other tag'
# > "My Tag, Second Tag, Some Other tag"

# remove a single tag
model.highlights_list = 'My Tag, Second Tag'
# > "My Tag, Second Tag"

# remove all tags
model.highlights_list = ''

# remember to persist changes
model.save
```

#### Querying
`EasyTags` does not offer any query helper scopes, but it's fairly easy to query without them.

##### Context relations
Upon the `easy_tags_on` declaration:
```ruby
easy_tags_on :highlights
```

the following relations will be auto-generated and made available for your model instance (`highlights` being an example context name):

| description                                  | relation                |
|----------------------------------------------|-------------------------|
| `has_many` to `EasyTags::Tag` relation       | highlights_tags         |
| `has_many` to `EasyTags::Taggings` relation  | highlights_taggings     |

- `EasyTags::Tag` model represents a single tag name
- `EasyTags::Taggings` represents a join table between your model and the `EasyTags::Tag` model, it also holds the tag context value

Find all model instances with a specific tag name:
```ruby
MyModel.joins(:highlights_tags).where(tags: { name: 'My Tag' })
```

Eager loading:
```ruby
MyModel.includes(:highlights_tags)
```

##### Global relations
Upon the `EasyTags::Taggable` inclusion
```ruby
include EasyTags::Taggable
```
the fallowing context independent relations will be auto-generated and made available for your model instance:

| description                                  | relation                                |
|----------------------------------------------|-----------------------------------------|
| `has_many` to `EasyTags::Taggings` relation  | has_many :taggings, as: :taggable       |
| `has_many` to `EasyTags::Tag` relation       | has_many :base_tags, through: :taggings |

You can use them for querying multiple contexts
```ruby
MyModel.joins(:base_tags).where(taggings: { context: %w[highlights billing_highlights] })
```

### Callbacks

#### Instance scope callbacks

```ruby
include EasyTags::Taggable

easy_tags_on(
  highlights: { after_add: :add_tag_callback, after_remove: -> (tagging) { puts "removed #{tagging.tag.name}" } }
)

def add_tag_callback(tagging)
  puts "added #{tagging.tag.name}"
end
```

#### Active Support Instrumentation custom notifications

##### Tag notifications

```ruby
ActiveSupport::Notifications.subscribe 'easy_tag.tag_added' do |tag|
  puts "added #{tag.name}"
end
```

```ruby
ActiveSupport::Notifications.subscribe 'easy_tag.tag_removed' do |tag|
  puts "removed #{tag.name}"
end
```

##### Tagging notifications

```ruby
ActiveSupport::Notifications.subscribe 'easy_tag.tagging_added.YOUR_MODEL_TABLEIZED.CONTEXT_NAME' do |tagging|
  puts "added #{tagging.tag.name}"
end
```

```ruby
ActiveSupport::Notifications.subscribe 'easy_tag.tagging_added.YOUR_MODEL_TABLEIZED.CONTEXT_NAME' do |tagging|
  puts "removed #{tagging.tag.name}"
end
```

### Dirty objects

`EasyTags` implements `ActiveModel::Dirty` attribute changes tracking fot all the context String accessors (the `CONTEXT_NAME_list` attributes)

```ruby
model.highlights
# []

model.highlights = ['Tag One', 'Tag Two']
# [
#     [0] "Tag One",
#     [1] "Tag Two"
# ]

model.changed?
# true

model.highlights_list_changed?
# true

model.highlights_list_was
# ""

model.highlights_list_change
# [
#     [0] "",
#     [1] "Tag One,Tag Two"
# ]

model.save
# true

model.changed?
# false

model.highlights_list_changed?
# false

model.previous_changes
# {
#     "highlights_list" => [
#         [0] nil,
#         [1] "Tag One,Tag Two"
#     ]
# }

model.highlights_list_previously_changed?
# true

model.highlights_list_previous_change
# [
#     [0] nil,
#     [1] "Tag One,Tag Two"
# ]
```

## Configuration

```ruby
# config/initializers/easy_tags.rb

EasyTags.setup do |config|
  config.tags_table = :tags
  config.taggings_table = :taggings
  config.parser = EasyTags::Parsers::Default
  config.generator = EasyTags::Generators::Default
end
```

You can customize db table names with `tags_table` and `taggings_table` options.

You can customize the parser and the generator to use different separators, filtering or processing.
The default parser uses comma as separator and is case sensitive.


## Testing
```
bundle exec appraisal install
bundle exec appraisal rspec
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/easy_tags. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
