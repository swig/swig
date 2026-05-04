require("evil_diamond_ns")

local s1 = evil_diamond_ns.spam()
assert(swig_type(s1) == "Blah::spam *")

local s2 = evil_diamond_ns.test(s1)
-- after casting to 'foo'
assert(swig_type(s2) == "Blah::foo *")
-- s2 point to same object s1 point to
assert(swig_equals(s1, s2))
