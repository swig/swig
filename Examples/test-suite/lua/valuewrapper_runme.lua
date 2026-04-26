require("import")
require("valuewrapper")
v=valuewrapper
catch_undef_globs() -- catch "undefined" global variables

assert(v.Xi ~= nil)
assert(v.YXi ~= nil)

x1 = v.Xi(5)

y1 =v.YXi()
assert(y1:spam(x1) == 0)
assert(y1:spam() == 0)
