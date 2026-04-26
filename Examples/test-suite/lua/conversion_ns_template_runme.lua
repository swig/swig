local v=require("conversion_ns_template")

local f = v.Foo_One()
assert(f ~= nil)
assert(swig_type(f) == "oss::Foo< oss::One > *")
assert(not pcall(function() v.Bar_One() end)) -- %ignore Bar<One>::Bar()
local b = v.Bar_One(13)
assert(b ~= nil)
assert(swig_type(b) == "oss::Bar< oss::One > *")
-- local b2 = v.Bar_create(12) TODO %rename(Bar_create) -> Bar<One>::Bar(int) fails!
local f2 = b:hello2() -- %rename(hello2) -> operator Foo<One>() { return new Foo<One>(); }
assert(f2 ~= nil)
assert(swig_type(f2) == "oss::Foo< oss::One > *")
assert(not pcall(function() v.Hi() end)) -- %ignore Hi::Hi()
local h = v.Hi(17)
assert(h ~= nil)
assert(swig_type(h) == "oss::Hi *")
-- local h2 = v.create(11) TODO %rename(create) -> Hi::Hi(int) fails!
