require("abstract_access")
catch_undef_globs() -- catch "undefined" global variables

-- trying to instantiate pure virtual classes
-- should fail
assert(not pcall(abstract_access.A))
assert(not pcall(abstract_access.B))
assert(not pcall(abstract_access.C))

-- instantiate object
d=abstract_access.D()

--call fn
assert(d:do_x()==1)
