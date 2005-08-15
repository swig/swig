require("import")	-- the import fn
import("ret_by_value")	-- import code

-- catch "undefined" global variables
setmetatable(getfenv(),{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

a = ret_by_value.get_test()
assert(a.myInt == 100)
assert(a.myShort == 200)
