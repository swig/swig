--Example using pointers to member functions
require("import")
require("member_pointer")
mp=member_pointer
catch_undef_globs() -- catch "undefined" global variables

function check(what, expected, actual)
	assert(expected == actual,"Failed: "..what.." Expected: "..expected.." Actual: "..actual)
end

-- Get the pointers
area_pt = mp.areapt()
perim_pt = mp.perimeterpt()

-- Create some objects
s = mp.Square(10)

-- Do some calculations
check ("Square area ", 100.0, mp.do_op(s,area_pt))
check ("Square perim", 40.0, mp.do_op(s,perim_pt))

-- Try the variables
-- these have to still be part of the 'member_pointer' table
memberPtr = mp.areavar
memberPtr = mp.perimetervar

check ("Square area ", 100.0, mp.do_op(s,mp.areavar))
check ("Square perim", 40.0, mp.do_op(s,mp.perimetervar))

-- Modify one of the variables
mp.areavar = perim_pt

check ("Square perimeter", 40.0, mp.do_op(s,mp.areavar))

-- Try the constants
memberPtr = mp.AREAPT
memberPtr = mp.PERIMPT
memberPtr = mp.NULLPT

check ("Square area ", 100.0, mp.do_op(s,mp.AREAPT))
check ("Square perim", 40.0, mp.do_op(s,mp.PERIMPT))

