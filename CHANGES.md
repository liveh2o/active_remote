# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [7.0.0]

### Changed

- Update to ActiveModel 7.0 [#96]

## [6.1.2]

### Added

- Add Ruby 3.1 compatibility [9477268]

## [6.1.1]

### Fixed

- Revert the reader and writer methods so they can be overridden [#95]

## [6.1.0]

### Changed

- Update to ActiveModel 6.1

## [6.0.3]

### Added

- Add Ruby 3.1 compatibility [45d8e26]

## [6.0.2]

### Fixed

- Fix association writer method (so it actually works) [85b369a]

## [6.0.1]

### Changed

- Pin to ActiveModel 6.0 (specs fail under 6.1)

## [6.0.0]

### Changed

- Update to ActiveModel 6.x

## [5.2.0]

### Changed

- Update to ActiveModel 5.2 to get major speed gains [#68]

### Removed

- Drop support for Rails 5.1
- Remove development dependency on protobuf-nats

## [5.1.1]

### Changed

- Include response errors in RemoteRecordNotSaved exception [#75]

## [5.1.0]

### Removed

- Drop support for Rails 5.0

## [5.0.1]

### Changed

- Include response errors in RemoteRecordNotSaved exception [#75]

## [5.0.0]

### Added

- Use Active Model attributes [#72]
- Use type casting from Active Model (custom types must be registered) [#71]
- Use query attributes from Active Record (string values such as 'FALSE', and '0' are now considered present) [#71]
- Add ability to execute remote calls on current object [#74]

### Fixed

Make query attributes more permissive [#73]

### Removed

- Drop support for Rails 4.2 (versions will match Rails version moving forward) [#71]

## [3.3.3]

### Added

- Register big_integer type #76

## [3.3.2]

### Changed

- Include response errors in RemoteRecordNotSaved exception [#75]

## [3.3.1]

### Fixed

- Fix unknown type error in Protobuf serializer [#70]

## [3.3.0]

### Added

- Add support for registering types that can be used to define attributes without using the existing `:type` or
  `:typecaster` options `attribute :name, :string` [#69]

## [3.2.2]

### Fixed

- Speed up boolean typecasting [#67, @abrandoned]

## [3.2.1]

### Changed

- Use `:remote_call` instead of of `rpc.execute` in persistence, search

## [3.2.0]

### Added

- Add ability to override default RPC endpoints [#66]

### Changed

- Require Active Model 4.x to 5.1 for compatibility

## [3.1.3]

### Changed

- Require Active Model 4.x for compatibility

### Fixed

- Cache and dup default attributes instead of building from scratch (4x speed boost on initialize) [#63, @film42]

## [3.1.2]

### Fixed

- Allow primary_key to be set on create [#61, @mattnichols]
- Change the behavior of DateTime types to gracefully handle invalid dates [#62, @brianstien]

## [3.1.1]

### Fixed

- Guard against undefined method errors in the Protobuf adapter [#59, @brianstien]

## [3.1.0]

### Added

- Bubble up the type of error given from Protobuf instead of a generic `ActiveRemoteError` [#58, @ryanbjones]

## [3.0.0]

### Fixed

- Improve performance of many methods including `respond_to?` and `new`. [#50]
- Change to internals of typecasting. Declaring `attribute :name, :type => Integer`
  will no longer affect performance negatively. [#56]

### Changed

- Refactor of attribute storage internals [#50]
- Refactor of instantiate from RPC codepath [#56]

### Removed

- Remove dependency on ActiveAttr [#48]
- Remove attribute defaults feature [#50]
- Remove core exts [#49]
- Remove deprecated rpc methods `.request`, `.request_type`, #execute`, `#remote_call`
  These methods are handled by the rpc adater now. [#49]
- Remove deprecated method `._active_remote_search_args` [#49]
- Remove deprecated `.parse_records` method [#49]
- Remove publication, `#publishable_hash` method [#49]
- Drop support for Rails 3 mass assignment protection. Add support for strong param
  enforcement for Rails 4+. [#50]
- Remove a method that was doing dirty tracking twice [#52]
- Extracted bulk methods to active_remote-bulk [#54]
- Removed search callbacks [#55]
