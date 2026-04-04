require("import")
require("exception_partial_info")

-- catch "undefined" global variables
setmetatable(_ENV,{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

imp=exception_partial_info.Impl()

-- trying to call throwing methods
-- should fail
assert(not pcall(function() imp:f1() end))
assert(not pcall(function() imp:f2() end))
