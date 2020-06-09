# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.5] - 2020-06-09
### Fixed
- Added association cache invalidation after tag changes are persisted
(fixes issue with explicit reload required to refresh `context_tags`)

## [0.2.4] - 2020-06-09
### Fixed
- Fixed tags eager loading

## [0.2.3] - 2020-01-15
### Added
- Rails 6.0 support

## [0.2.2] - 2019-10-24
### Fixed
- Fixed inspect and compare for context objects (delegate to tags list) that may have affected debug and testing

## [0.2.1] - 2019-10-24
### Fixed
- Fixed `.add` and `.remove` methods not implementing properly dirty behavior

## [0.2.0] - 2019-09-12
### Added
- `[context]_list_persisted` interface method for accessing persisted/previous tag list string

## [0.1.0] - 2019-07-15
Initial release

[Unreleased]: https://github.com/iiwo/easy_tagscompare/v0.2.5...HEAD
[0.2.5]: https://github.com/iiwo/easy_tags/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/iiwo/easy_tags/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/iiwo/easy_tags/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/iiwo/easy_tags/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/iiwo/easy_tags/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/iiwo/easy_tags/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/iiwo/easy_tags/releases/tag/v0.1.0
