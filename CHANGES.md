# ActiveRemote Changes

3.3.1
----------

- Fix unknown type error in Protobuf serializer [#70]

3.3.0
----------

- Add support for registering types that can be used to define attributes without using the existing `:type` or
  `:typecaster` options  `attribute :name, :string` [#69]

3.2.2
----------

- Speed up boolean typecasting [#67, @abrandoned]

3.2.1
----------

- Use `:remote_call` instead of of `rpc.execute` in persistence, search

3.2.0
----------

- Add ability to override default RPC endpoints [#66]
- Require Active Model 4.x to 5.1 for compatibility

3.1.3
----------

- Require Active Model 4.x for compatibility
- Cache and dup default attributes instead of building from scratch (4x speed boost on initialize) [#63, @film42]

3.1.2
----------

- Allow primary_key to be set on create [#61, @mattnichols]
- Change the behavior of DateTime types to gracefully handle invalid dates [#62, @brianstien]

3.1.1
----------

- Guard against undefined method errors in the Protobuf adapter [#59, @brianstien]

3.1.0
----------

- Bubble up the type of error given from Protobuf instead of a generic `ActiveRemoteError` [#58, @ryanbjones]

3.0.0
----------

- Remove dependency on ActiveAttr [#48]
- Remove attribute defaults feature [#50]
- Remove core exts [#49]
- Remove deprecated rpc methods `.request`, `.request_type`, #execute`, `#remote_call`
  These methods are handled by the rpc adater now. [#49]
- Remove deprecated method `._active_remote_search_args` [#49]
- Remove deprecated `.parse_records` method [#49]
- Remove publication, `#publishable_hash` method [#49]
- Drop support for Rails 3 mass assignment protection.  Add support for strong param
  enforcement for Rails 4+. [#50]
- Improve performance of many methods including `respond_to?` and `new`. [#50]
- Refactor of attribute storage internals [#50]
- Remove a method was was doign dirty tracking twice [#52]
- Extracted bulk methods to active_remote-bulk [#54]
- Removed search callbacks [#55]
- Refactor of instantiate from rpc codepath [#56]
- Change to internals of typecasting.  Declaring `attribute :name, :type => Integer`
  will no longer affect performance negatively. [#56]
