# ActiveRemote Changes

3.0.0
----------

- Remove dependency on ActiveAttr [#48]
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
