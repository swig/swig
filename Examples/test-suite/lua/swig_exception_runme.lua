local v=require("swig_exception")

local c = v.Circle(10)
local s = v.Square(10)
assert(v.Shape.nshapes == 2, "Shape.nshapes should be 2 not " .. v.Shape.nshapes)

----- Throw exception -----
local err, msg = pcall(function() c:throwException() end)
assert(not err)
assert(msg == "SWIG_SystemError:OK")

----- Delete everything -----
c = nil
s = nil
collectgarbage()
assert(v.Shape.nshapes == 0, "Shape.nshapes should be 0 not " .. v.Shape.nshapes)
