require("import")
require("grouping")
g=grouping
catch_undef_globs() -- catch "undefined" global variables

assert(g.test1(5) == 5)
g.test2(42) -- Return value is int* packed into userdata. We can't do anything with it

assert(g.test3 == 37)
g.test3 = 42
assert(g.test3 == 42)

assert(g.NEGATE ~= nil)
assert(g.do_unary(5, g.NEGATE) == -5)
