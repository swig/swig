require("import")
require("fvirtual")
f=fvirtual
catch_undef_globs() -- catch "undefined" global variables

n1 = f.Node()
n2 = f.Node()
assert(n1:addChild(n2) == 1)

ns = f.NodeSwitch()
assert(ns:addChild(n2) == 2)
assert(ns:addChild(ns) == 2)
assert(ns:addChild(n1, false) == 3)
