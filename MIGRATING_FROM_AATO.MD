<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Migrating from ActsAsTaggableOn to EasyTags](#migrating-from-actsastaggableon-to-easytags)
  - [Database](#database)
  - [Features](#features)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Migrating from ActsAsTaggableOn to EasyTags

 ### Database
 `EasyTags` uses the same table structure as `ActsAsTaggableOn` - you most probably do not have to do any migrations

 ### Features
 in comparison to `ActsAsTaggableOn` some features/behaviors were deliberately not included in `EasyTags`:
 - singularization/pluralizion of context names (we use flat naming)
 - `Tag Ownership`
 - Query helpers (ie. `tagged_with`)
 - statistic helpers (ie. `most_used`, `least_used`)
 - `Dynamic Tag Contexts`

 ### Configuration
 `EasyTags` does not implement configuration options like:
 `delimiter`, `force_lowercase`, `force_parameterize` etc.

 you can use custom parser for that

 ### Auto-generated context methods
`EasyTags` uses consistent types and naming

|                                    | `easy_tags`          | `acts_as_tagabble_on` |
|------------------------------------|----------------------|-----------------------|
| `has_many` to `Tag` relation       | context_tags         | context(pluralized)               |
| `has_many` to `Taggings` relation  | context_taggings     | context(singularized)_taggings      |
| set tags using string of tag names | context_list=(value) | context(singularized)_list=(value)  |
| get string of tag names            | context_list         | -                     |
| set tags with array of tag names   | context=(value)      | context(singularized)_list=(value)  |
| get array of tag names             | context              | context(singularized)_list                    |

