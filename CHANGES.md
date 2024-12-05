# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [7.1.0] - 2024-12-04

### Changed

- Update to ActiveModel 7.1 [#100](https://github.com/liveh2o/active_remote/pulls/100)

### Added

- Add `find_by` to the `Search` module to return the first record without raising `RemoteRecordNotFound` [#83](https://github.com/liveh2o/active_remote/pull/83)

## [7.0.0] - 2024-06-15

### Changed

- Update to ActiveModel 7.0 [#96](https://github.com/liveh2o/active_remote/pulls/96)

## [6.1.2] - 2024-06-15

### Added

- Add Ruby 3.1 compatibility [9477268](https://github.com/liveh2o/active_remote/commit/9477268)

## [6.1.1] - 2022-09-07

### Fixed

- Revert the reader and writer methods so they can be overridden [#95](https://github.com/liveh2o/active_remote/pull/95)

## [6.1.0] - 2022-08-24

### Changed

- Update to ActiveModel 6.1

## [6.0.3] - 2024-06-15

### Added

- Add Ruby 3.1 compatibility [45d8e26](https://github.com/liveh2o/active_remote/commit/45d8e26)

## [6.0.2] - 2022-06-17

### Fixed

- Fix association writer method (so it actually works) [85b369a](https://github.com/liveh2o/active_remote/commit/85b369a)

## [6.0.1] - 2022-02-11

### Changed

- Pin to ActiveModel 6.0 (specs fail under 6.1)

## [6.0.0]- 2022-02-10

### Changed

- Update to ActiveModel 6.x

## [5.2.0] - 2020-05-21

### Changed

- Update to ActiveModel 5.2 to get major speed gains [#68](https://github.com/liveh2o/active_remote/pull/68)

### Removed

- Drop support for Rails 5.1
- Remove development dependency on protobuf-nats

## [5.1.1] - 2019-04-16

### Changed

- Include response errors in RemoteRecordNotSaved exception [#75](https://github.com/liveh2o/active_remote/pull/75)

## [5.1.0] - 2019-01-26

### Removed

- Drop support for Rails 5.0

## [5.0.1] - 2019-04-16

### Changed

- Include response errors in RemoteRecordNotSaved exception [#75](https://github.com/liveh2o/active_remote/pull/75)

## [5.0.0] - 2019-01-26

### Added

- Use Active Model attributes [#72](https://github.com/liveh2o/active_remote/pull/72)
- Use type casting from Active Model (custom types must be registered) [#71](https://github.com/liveh2o/active_remote/pull/71)
- Use query attributes from Active Record (string values such as 'FALSE', and '0' are now considered present) [#71](https://github.com/liveh2o/active_remote/pull/71)
- Add ability to execute remote calls on current object [#74](https://github.com/liveh2o/active_remote/pull/74)

### Fixed

Make query attributes more permissive [#73](https://github.com/liveh2o/active_remote/pull/73)

### Removed

- Drop support for Rails 4.2 (versions will match Rails version moving forward) [#71](https://github.com/liveh2o/active_remote/pull/71)

## [3.3.3] - 2020-01-10

### Added

- Register big_integer type [#76](https://github.com/liveh2o/active_remote/pull/76)

## [3.3.2] - 2019-04-16

### Changed

- Include response errors in RemoteRecordNotSaved exception [#75](https://github.com/liveh2o/active_remote/pull/75)

## [3.3.1] - 2019-01-08

### Fixed

- Fix unknown type error in Protobuf serializer [#70](https://github.com/liveh2o/active_remote/pull/70)

## [3.3.0] - 2019-01-08

### Added

- Add support for registering types that can be used to define attributes without using the existing `:type` or
  `:typecaster` options `attribute :name, :string` [#69](https://github.com/liveh2o/active_remote/pull/69)

## [3.2.2] - 2018-12-31

### Fixed

- Speed up boolean typecasting [#67, @abrandoned](https://github.com/liveh2o/active_remote/pull/67)

## [3.2.1] - 2018-11-11

### Changed

- Use `:remote_call` instead of of `rpc.execute` in persistence, search

## [3.2.0] - 2018-10-30

### Added

- Add ability to override default RPC endpoints [#66](https://github.com/liveh2o/active_remote/pull/66)

### Changed

- Require Active Model 4.x to 5.1 for compatibility

## [3.1.3] - 2018-07-10

### Changed

- Require Active Model 4.x for compatibility

### Fixed

- Cache and dup default attributes instead of building from scratch (4x speed boost on initialize) [#63, @film42](https://github.com/liveh2o/active_remote/pull/63)

## [3.1.2] - 2018-02-28

### Fixed

- Allow primary_key to be set on create [#61, @mattnichols](https://github.com/liveh2o/active_remote/pull/61)
- Change the behavior of DateTime types to gracefully handle invalid dates [#62, @brianstien](https://github.com/liveh2o/active_remote/pull/61)

## [3.1.1] - 2017-05-05

### Fixed

- Guard against undefined method errors in the Protobuf adapter [#59, @brianstien](https://github.com/liveh2o/active_remote/pull/59)

## [3.1.0] - 2017-04-27

### Added

- Bubble up the type of error given from Protobuf instead of a generic `ActiveRemoteError` [#58, @ryanbjones](https://github.com/liveh2o/active_remote/pull/58)

## [3.0.0] - 2017-03-02

### Fixed

- Improve performance of many methods including `respond_to?` and `new`. [#50](https://github.com/liveh2o/active_remote/pull/50)
- Change to internals of typecasting. Declaring `attribute :name, :type => Integer`
  will no longer affect performance negatively. [#56](https://github.com/liveh2o/active_remote/pull/56)

### Changed

- Refactor of attribute storage internals [#50](https://github.com/liveh2o/active_remote/pull/50)
- Refactor of instantiate from RPC codepath [#56](https://github.com/liveh2o/active_remote/pull/56)

### Removed

- Remove dependency on ActiveAttr [#48](https://github.com/liveh2o/active_remote/pull/48)
- Remove attribute defaults feature [#50](https://github.com/liveh2o/active_remote/pull/50)
- Remove core exts [#49](https://github.com/liveh2o/active_remote/pull/49)
- Remove deprecated rpc methods `.request`, `.request_type`, #execute`, `#remote_call`
  These methods are handled by the rpc adater now. [#49](https://github.com/liveh2o/active_remote/pull/49)
- Remove deprecated method `._active_remote_search_args` [#49](https://github.com/liveh2o/active_remote/pull/49)
- Remove deprecated `.parse_records` method [#49](https://github.com/liveh2o/active_remote/pull/49)
- Remove publication, `#publishable_hash` method [#49](https://github.com/liveh2o/active_remote/pull/49)
- Drop support for Rails 3 mass assignment protection. Add support for strong param
  enforcement for Rails 4+. [#50](https://github.com/liveh2o/active_remote/pull/50)
- Remove a method that was doing dirty tracking twice [#52](https://github.com/liveh2o/active_remote/pull/52)
- Extracted bulk methods to active_remote-bulk [#54](https://github.com/liveh2o/active_remote/pull/54)
- Removed search callbacks [#55](https://github.com/liveh2o/active_remote/pull/55)
