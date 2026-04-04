local v=require("overload_rename")

local f = v.Foo(1, 1)
-- v.Foo(1) TODO constructor with default value is missing
f = v.Foo(1, 1)
f = v.Foo(1, 1, 1)
--[[ TODO %rename does not work
f = v.Foo_int(1, 1)
f = v.Foo_int(1, 1, 1)
]]
