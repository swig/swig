local v=require("smart_pointer_static")


-- This doesn't actually test any smart pointer stuff, just that static
-- vs non-static overloading is wrapped suitable (fixed in SWIG 4.2.0).
--
-- We can't make the same wrapped method both static and non-static in PHP
-- so we make it non-static, and that at least allows the static version
-- to be called via an object.
local foo2 = v.Foo2()
assert(swig_type(foo2) == "Foo2 *")
-- assert(foo2:sum(1,2) == 3) TODO static method shadow non-static method
assert(v.Foo2.sum(1,2,3) == 6)

local m = v.MyHandle_Foo2()
local f2 = m:__deref__()
assert(swig_type(f2) == "Foo2 *")
