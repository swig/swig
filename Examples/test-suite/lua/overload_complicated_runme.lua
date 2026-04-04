require("import")
require("overload_complicated")
oc=overload_complicated
catch_undef_globs() -- catch "undefined" global variables

assert(oc.foo(1,1,"test",1) == 15)

p1 = oc.Pop(nil)
p1 = oc.Pop(nil,false)

assert(p1:hip(false) == 701)
assert(p1:hip(nil) == 702)

assert(p1:hop(false) == 801)
assert(p1:hop(nil) == 805)

assert(oc.muzak(false) == 3001)
assert(oc.muzak(nil) == 3002)
