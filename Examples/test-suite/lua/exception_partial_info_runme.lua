require("exception_partial_info")
catch_undef_globs() -- catch "undefined" global variables

imp=exception_partial_info.Impl()

-- trying to call throwing methods
-- should fail
assert(not pcall(function() imp:f1() end))
assert(not pcall(function() imp:f2() end))
