// Example using pointers to member functions

var member_pointer = require("member_pointer");

function check(what, expected, actual) {
    if (expected != actual) {
        throw new Error(
            "Failed: ", what, " Expected: ", expected, " Actual: ", actual);
    }
}

// Get the pointers

area_pt = member_pointer.areapt();
perim_pt = member_pointer.perimeterpt();

// Create some objects

s = new member_pointer.Square(10);

// Do some calculations

check("Square area ", 100.0, member_pointer.do_op(s, area_pt));
check("Square perim", 40.0, member_pointer.do_op(s, perim_pt));

memberPtr = member_pointer.areavar;
memberPtr = member_pointer.perimetervar;

// Try the variables
check("Square area ", 100.0, member_pointer.do_op(s, member_pointer.areavar));
check("Square perim", 40.0, member_pointer.do_op(s, member_pointer.perimetervar));

// Modify one of the variables
member_pointer.areavar = perim_pt;

check("Square perimeter", 40.0, member_pointer.do_op(s, member_pointer.areavar));

// Try the constants
memberPtr = member_pointer.AREAPT;
memberPtr = member_pointer.PERIMPT;
memberPtr = member_pointer.NULLPT;

check("Square area ", 100.0, member_pointer.do_op(s, member_pointer.AREAPT));
check("Square perim", 40.0, member_pointer.do_op(s, member_pointer.PERIMPT));

// Typedefs
check("Square perim", 40.0, member_pointer.do_op_td(s, perim_pt));

check("Add by value", 3, member_pointer.call1(member_pointer.ADD_BY_VALUE, 1, 2));
check("Add by pointer", 7, member_pointer.call2(member_pointer.ADD_BY_POINTER, 3, 4));
check("Add by reference", 11, member_pointer.call3(member_pointer.ADD_BY_REFERENCE, 5, 6));
