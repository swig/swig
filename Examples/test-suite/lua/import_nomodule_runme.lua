require("import")	-- the import fn
import("import_nomodule")	-- import code

-- catch "undefined" global variables
setmetatable(getfenv(),{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

f = import_nomodule.create_Foo()
import_nomodule.test1(f,42)
import_nomodule.delete_Foo(f)

b = import_nomodule.Bar()
import_nomodule.test1(b,37)

collectgarbage()