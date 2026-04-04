local v=require("template_classes")

-- This test is just testing incorrect number of arguments/parameters checking
local point = v.PointInt()
local rectangle = v.RectangleInt()
rectangle:setPoint(point)
rectangle:getPoint()
v.RectangleInt.static_noargs()
v.RectangleInt.static_onearg(1)
assert(not pcall(function() rectangle.setPoint() end))
assert(not pcall(function() rectangle.getPoint(0) end))
assert(not pcall(function() RectangleInt.static_noargs(0) end))
assert(not pcall(function() RectangleInt.static_onearg() end))
