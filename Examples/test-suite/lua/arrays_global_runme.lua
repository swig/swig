require("import")
require("arrays_global")
ag = arrays_global
catch_undef_globs() -- catch "undefined" global variables

assert(ag.BeginString_FIX44a == "FIX.a.a")
assert(ag.BeginString_FIX44b == "FIX.b.b")

assert(ag.BeginString_FIX44c == "FIX.c.c")
assert(ag.BeginString_FIX44d == "FIX.d.d")
