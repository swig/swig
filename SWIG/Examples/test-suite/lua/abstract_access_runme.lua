require("import")	-- the import fn
import("abstract_access")	-- import code

-- catch "undefined" global variables
setmetatable(getfenv(),{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

-- trying to instantiate pure virual classes
-- should fail
assert(pcall(abstract_access.A)==false)
assert(pcall(abstract_access.B)==false)
assert(pcall(abstract_access.C)==false)

-- instantiate object
d=abstract_access.D()

--call fn
assert(d:do_x()==1)
