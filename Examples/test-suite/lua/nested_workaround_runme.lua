require("import")
require("nested_workaround")
nw=nested_workaround
catch_undef_globs() -- catch "undefined" global variables

i1 = nw.Inner(5)
assert(i1:getValue() == 5)
i1:setValue(7)
assert(i1:getValue() == 7)

o1 = nw.Outer()
i2 = o1:createInner(9)
assert(i2:getValue() == 9)
i2:setValue(11)
assert(o1:getInnerValue(i2) == 11)

i3 = o1:doubleInnerValue(i2)
assert(i3:getValue() == 22)
