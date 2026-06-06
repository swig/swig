// Example using pointers to member functions
var member_pointer_const = require("member_pointer_const");

function check(what, expected, actual) {
    if (expected != actual) {
        throw new Error(
            "Failed: ", what, " Expected: ", expected, " Actual: ", actual);
    }
}

// Get the pointers

area_pt = member_pointer_const.areapt();
perim_pt = member_pointer_const.perimeterpt();

// Create some objects

s = new member_pointer_const.Square(10);

// Do some calculations

check("Square area ", 100.0, member_pointer_const.do_op(s, area_pt));
check("Square perim", 40.0, member_pointer_const.do_op(s, perim_pt));

memberPtr = member_pointer_const.areavar;
memberPtr = member_pointer_const.perimetervar;

// Try the variables
check("Square area ", 100.0, member_pointer_const.do_op(s, member_pointer_const.areavar));
check("Square perim", 40.0, member_pointer_const.do_op(s, member_pointer_const.perimetervar));

// Modify one of the variables
member_pointer_const.areavar = perim_pt;

check("Square perimeter", 40.0, member_pointer_const.do_op(s, member_pointer_const.areavar));

// Try the constants
memberPtr = member_pointer_const.AREAPT;
memberPtr = member_pointer_const.PERIMPT;
memberPtr = member_pointer_const.NULLPT;

check("Square area ", 100.0, member_pointer_const.do_op(s, member_pointer_const.AREAPT));
check("Square perim", 40.0, member_pointer_const.do_op(s, member_pointer_const.PERIMPT));

// Typedefs
check("Square perim", 40.0, member_pointer_const.do_op_td(s, perim_pt));

check("Add by value", 3, member_pointer_const.call1(member_pointer_const.ADD_BY_VALUE, 1, 2));
// TODO: For some reason, these are commented out in the shared interface file?
//check("Add by pointer", 7, member_pointer_const.call2(member_pointer_const.ADD_BY_POINTER, 3, 4));
//check("Add by reference", 11, member_pointer_const.call3(member_pointer_const.ADD_BY_REFERENCE, 5, 6));
