require("import")
require("li_factory")

-- moving to global
for k,v in pairs(li_factory) do _G[k]=v end

-- catch "undefined" global variables
setmetatable(_ENV,{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

circle = Geometry_create(Geometry_CIRCLE)
r = circle:radius()
assert(r == 1.5)

point = Geometry_create(Geometry_POINT)
w = point:width()
assert(w == 1.0)
