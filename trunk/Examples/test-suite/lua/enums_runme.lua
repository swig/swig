require("import")	-- the import fn
import("enums")	-- import lib

-- catch "undefined" global variables
setmetatable(getfenv(),{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

-- check values
assert(enums.CSP_ITERATION_FWD==0)
assert(enums.CSP_ITERATION_BWD==11)
assert(enums.ABCDE==0)
assert(enums.FGHJI==1)
assert(enums.boo==0)
assert(enums.hoo==5)
assert(enums.globalinstance1==0)
assert(enums.globalinstance2==1)
assert(enums.globalinstance3==30)
assert(enums.AnonEnum1==0)
assert(enums.AnonEnum2==100)

-- no point in checking fns, C will allow any value
