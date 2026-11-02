// Example using pointers to member functions

var member_pointer = require("member_pointer");

function check(what, expected, actual) {
    if (expected != actual) {
        throw new Error(
            "Failed: ", what, " Expected: ", expected, " Actual: ", actual);
    }
}

// Only napi throws a TypeError, so check the message
function check_type_error(what, f) {
    try {
        f();
    } catch (e) {
        if (e.message.indexOf("argument 2 of type") === -1)
            throw e;
        return;
    }
    throw new Error(what + " accepted");
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

// Const references to member pointers
check("Square area", 100.0, member_pointer.do_op_cref(s, area_pt));
check("Square perim", 40.0, member_pointer.do_op_cref(s, member_pointer.perimetervar_td_cref()));
check("Square perim", 40.0, member_pointer.do_op(s, member_pointer.perimetervar_td_cref()));
check_type_error("do_op_cref with ADD_BY_VALUE", function() { member_pointer.do_op_cref(s, member_pointer.ADD_BY_VALUE); });

check("Add by value", 3, member_pointer.call1(member_pointer.ADD_BY_VALUE, 1, 2));
check("Add by pointer", 7, member_pointer.call2(member_pointer.ADD_BY_POINTER, 3, 4));
check("Add by reference", 11, member_pointer.call3(member_pointer.ADD_BY_REFERENCE, 5, 6));

// Overloaded on the member pointer type
check("Overload by value", 3, member_pointer.call_overloaded(member_pointer.ADD_BY_VALUE, 1, 2));
check("Overload by pointer", -7, member_pointer.call_overloaded(member_pointer.ADD_BY_POINTER, 3, 4));
check("Overload by int", 110, member_pointer.call_overloaded(10, 5, 6));

// Overloaded on a member pointer and a pointer, only the pointer taking null
check("Overload by member pointer", 3, member_pointer.memberpt_or_pointer(member_pointer.ADD_BY_VALUE));
check("Overload by pointer", 10, member_pointer.memberpt_or_pointer(new member_pointer.Funktions()));
check("Overload by null", 20, member_pointer.memberpt_or_pointer(null));

// null is not a member pointer
check_type_error("do_op with null", function() { member_pointer.do_op(s, null); });
