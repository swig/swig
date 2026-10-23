require("inctest")

local a = inctest.A()
local b = inctest.B()

-- Check the import in subdirectory worked
assert(inctest.importtest1(5) == 15, "import test 1 failed")
assert(inctest.importtest2("black") == "white", "import test 2 failed")
