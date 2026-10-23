require("wallkw")

assert(wallkw.c_clone() == "clone", "clone_c")
assert(wallkw._delegate() == "delegate", "delegate")
assert(wallkw._pass() == "pass", "pass")
assert(wallkw._alias() == "alias", "alias")
assert(wallkw.C_rescue() == "rescue", "rescue")
