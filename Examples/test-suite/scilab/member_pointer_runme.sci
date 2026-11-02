exec("swigtest.start", -1);

s = new_Square(10);

// Functions
checkequal(do_op(s, areapt()), 100.0, "Square area");
checkequal(do_op(s, perimeterpt()), 40.0, "Square perimeter");

// Variables
checkequal(do_op(s, areavar_get()), 100.0, "Square area");
areavar_set(perimeterpt());
checkequal(do_op(s, areavar_get()), 40.0, "Square perimeter");

// Constants
checkequal(do_op(s, AREAPT_get()), 100.0, "Square area");
checkequal(do_op(s, PERIMPT_get()), 40.0, "Square perimeter");

// Const references to member pointers
checkequal(do_op_cref(s, areapt()), 100.0, "Square area");
checkequal(do_op_cref(s, perimetervar_td_cref()), 40.0, "Square perimeter");
checkequal(do_op(s, perimetervar_td_cref()), 40.0, "Square perimeter");
ierr = execstr("do_op_cref(s, ADD_BY_VALUE_get())", "errcatch");
if ierr == 0 then swigtesterror("do_op_cref(s, ADD_BY_VALUE_get()) error expected"); end

// Overloaded on the member pointer type
checkequal(call_overloaded(ADD_BY_VALUE_get(), 1, 2), 3, "Overload by value");
checkequal(call_overloaded(ADD_BY_POINTER_get(), 3, 4), -7, "Overload by pointer");
checkequal(call_overloaded(10, 5, 6), 110, "Overload by int");

delete_Square(s);

exec("swigtest.quit", -1);
