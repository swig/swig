# Example using pointers to member functions

member_pointer

function check(what,expected,actual)
  if (expected != actual)
    error ("Failed: %s, Expected: %f, Actual: %f",what,expected,actual);
  endif
end

# Get the pointers

area_pt = areapt;
perim_pt = perimeterpt;

# Create some objects

s = Square(10);

# Do some calculations

check ("Square area ", 100.0, do_op(s,area_pt));
check ("Square perim", 40.0, do_op(s,perim_pt));

memberPtr = cvar.areavar;
memberPtr = cvar.perimetervar;

# Try the variables
check ("Square area ", 100.0, do_op(s,cvar.areavar));
check ("Square perim", 40.0, do_op(s,cvar.perimetervar));

# Modify one of the variables
cvar.areavar = perim_pt;

check ("Square perimeter", 40.0, do_op(s,cvar.areavar));

# Try the constants

memberPtr = AREAPT;
memberPtr = PERIMPT;
memberPtr = NULLPT;

check ("Square area ", 100.0, do_op(s,AREAPT));
check ("Square perim", 40.0, do_op(s,PERIMPT));

# Const references to member pointers
check ("Square area", 100.0, do_op_cref(s,area_pt));
check ("Square perim", 40.0, do_op_cref(s,perimetervar_td_cref()));
check ("Square perim", 40.0, do_op(s,perimetervar_td_cref()));
try
  do_op_cref(s,ADD_BY_VALUE);
  error("do_op_cref accepted ADD_BY_VALUE");
catch e
  if (isempty(strfind(e.message, "SWIG_TypeError"))); rethrow(e); endif
end_try_catch

# Overloaded on the member pointer type
check ("Overload by value", 3, call_overloaded(ADD_BY_VALUE, 1, 2));
check ("Overload by pointer", -7, call_overloaded(ADD_BY_POINTER, 3, 4));
check ("Overload by int", 110, call_overloaded(10, 5, 6));
