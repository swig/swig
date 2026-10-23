local v=require("evil_diamond_prop")

local foo=v.foo()
assert(swig_type(foo) == "foo *")
assert(1 == foo._foo, "1==foo._foo")

-- bar inherit foo
local bar=v.bar()
assert(swig_type(bar) == "bar *")
assert(1 == bar._foo, "1==bar._foo")
assert(2 == bar._bar, "2==bar._bar")

-- Cast bar to 'foo'
local f = v.test(bar)
assert(swig_type(f) == "foo *")
assert(1 == f._foo, "1==(foo&)bar._foo")
assert(swig_equals(f, bar))

-- baz inherit foo
local baz=v.baz()
assert(swig_type(baz) == "baz *")
assert(1 == baz._foo, "1==baz._foo")
assert(3 == baz._baz, "3==baz._baz")

-- Cast baz to 'foo'
local f = v.test(baz)
assert(swig_type(f) == "foo *")
assert(1 == f._foo, "1==(foo&)baz._foo")
assert(swig_equals(f, baz))

-- spam inherit bar and baz whom both inherit foo
local spam=v.spam()
assert(swig_type(spam) == "spam *")
assert(1 == spam._foo, "1==spam._foo")
assert(2 == spam._bar, "2==spam._bar")
assert(3 == spam._baz, "3==spam._baz")
assert(4 == spam._spam, "4==spam._spam")

-- Cast spam to 'foo'
local f = v.test(spam)
assert(swig_type(f) == "foo *")
assert(1 == f._foo, "1==(foo&)spam._foo")
assert(swig_equals(f, spam))
