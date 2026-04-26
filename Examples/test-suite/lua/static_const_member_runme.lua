require("import")
require("static_const_member")
scm=static_const_member
catch_undef_globs() -- catch "undefined" global variables

assert(scm.X.PN == 0)
assert(scm.X.CN == 1)
assert(scm.X.EN == 2)
assert(scm.X.CHARTEST == "A")

-- Old-style bindings
assert(scm.X_PN == 0)
assert(scm.X_CN == 1)
assert(scm.X_EN == 2)
assert(scm.X_CHARTEST == "A")


