local v=require("member_pointer_const")

function check(what, expected, actual)
    assert(expected == actual, "Failed: " .. what .. " Expected: " .. expected .. " Actual: " .. actual)
end

-- Get the pointers
local area_pt = v.areapt()
local perim_pt = v.perimeterpt()

-- Create some objects
local s = v.Square(10)

-- Do some calculations
check("Square area ", 100, v.do_op(s, area_pt))
check("Square perim", 40, v.do_op(s, perim_pt))

local memberPtr = v.areavar
local memberPtr = v.perimetervar

-- Try the variables
check("Square area ", 100, v.do_op(s, v.areavar))
check("Square perim", 40, v.do_op(s, v.perimetervar))

-- Modify one of the variables
v.areavar = perim_pt
check("Square perimeter", 40, v.do_op(s, v.areavar))

-- Try the constants
memberPtr = v.AREAPT
memberPtr = v.PERIMPT
memberPtr = v.NULLPT
check("Square area ", 100, v.do_op(s, v.AREAPT))
check("Square perim", 40, v.do_op(s, v.PERIMPT))

-- Typedefs
check("Square perim", 40, v.do_op_td(s, perim_pt))
check("Add by value", 3, v.call1(v.ADD_BY_VALUE, 1, 2))
