--Example using pointers to member functions

require("import")	-- the import fn
import("member_pointer")	-- import code

for k,v in pairs(member_pointer) do _G[k]=v end

function check(what, expected, actual)
	assert(expected == actual,"Failed: "..what.." Expected: "..expected.." Actual: "..actual)
end

-- Get the pointers
area_pt = areapt()
perim_pt = perimeterpt()

-- Create some objects
s = Square(10)

-- Do some calculations
check ("Square area ", 100.0, do_op(s,area_pt))
check ("Square perim", 40.0, do_op(s,perim_pt))

-- Try the variables
-- these have to still be part of the 'member_pointer' table
memberPtr = member_pointer.areavar
memberPtr = member_pointer.perimetervar

check ("Square area ", 100.0, do_op(s,member_pointer.areavar))
check ("Square perim", 40.0, do_op(s,member_pointer.perimetervar))

-- Modify one of the variables
member_pointer.areavar = perim_pt

check ("Square perimeter", 40.0, do_op(s,member_pointer.areavar))

-- Try the constants
memberPtr = AREAPT
memberPtr = PERIMPT
memberPtr = NULLPT

check ("Square area ", 100.0, do_op(s,AREAPT))
check ("Square perim", 40.0, do_op(s,PERIMPT))

