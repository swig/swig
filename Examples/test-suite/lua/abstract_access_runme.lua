require("import")
require("abstract_access")
catch_undef_globs() -- catch "undefined" global variables

-- trying to instantiate pure virtual classes
-- should fail
assert(pcall(abstract_access.A)==false)
assert(pcall(abstract_access.B)==false)
assert(pcall(abstract_access.C)==false)

-- instantiate object
d=abstract_access.D()

--call fn
assert(d:do_x()==1)
