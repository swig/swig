--Example using pointers to member functions
mp=require("member_pointer")
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

-- Const references to member pointers
check ("Square area", 100.0, mp.do_op_cref(s,area_pt))
check ("Square perim", 40.0, mp.do_op_cref(s,mp.perimetervar_td_cref()))
check ("Square perim", 40.0, mp.do_op(s,mp.perimetervar_td_cref()))
assert(not pcall(mp.do_op_cref, s, mp.ADD_BY_VALUE))

-- Overloaded on the member pointer type
check ("Overload by value", 3, mp.call_overloaded(mp.ADD_BY_VALUE, 1, 2))
check ("Overload by pointer", -7, mp.call_overloaded(mp.ADD_BY_POINTER, 3, 4))
check ("Overload by int", 110, mp.call_overloaded(10, 5, 6))

-- Overloaded on a member pointer and a pointer, only the pointer taking nil
check ("Overload by member pointer", 3, mp.memberpt_or_pointer(mp.ADD_BY_VALUE))
check ("Overload by pointer", 10, mp.memberpt_or_pointer(mp.Funktions()))
check ("Overload by nil", 20, mp.memberpt_or_pointer(nil))
