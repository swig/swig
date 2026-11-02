# Example using pointers to member functions

if [ catch { load ./member_pointer[info sharedlibextension] Member_pointer} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

proc check {what expected actual} {
  if {$expected != $actual } {
    error "Failed: $what , Expected: $expected , Actual: $actual"
  }
}

proc check_type_error {what script} {
  if {![catch {uplevel 1 $script} err_msg]} { error "$what accepted" }
  if {![string match "*TypeError*" $err_msg]} { error "$what: $err_msg" }
}
# Get the pointers

set area_pt [ areapt ]
set perim_pt [ perimeterpt ]

# Create some objects

set s [Square -args 10]

# Do some calculations

check "Square area " 100.0 [do_op $s $area_pt]
check "Square perim" 40.0 [do_op $s $perim_pt]

set memberPtr $areavar
set memberPtr $perimetervar

# Try the variables
check "Square area " 100.0 [do_op $s $areavar]
check "Square perim" 40.0 [do_op $s $perimetervar]

# Modify one of the variables
set areavar $perim_pt

check "Square perimeter" 40.0 [do_op $s $areavar]

# Try the constants

set memberPtr $AREAPT
set memberPtr $PERIMPT
set memberPtr $NULLPT

check "Square area " 100.0 [do_op $s $AREAPT]
check "Square perim" 40.0 [do_op $s $PERIMPT]

# Const references to member pointers
check "Square area" 100.0 [do_op_cref $s $area_pt]
check "Square perim" 40.0 [do_op_cref $s [perimetervar_td_cref]]
check "Square perim" 40.0 [do_op $s [perimetervar_td_cref]]
check_type_error "do_op_cref with ADD_BY_VALUE" { do_op_cref $s $ADD_BY_VALUE }

# Overloaded on the member pointer type
check "Overload by value" 3 [call_overloaded $ADD_BY_VALUE 1 2]
check "Overload by pointer" -7 [call_overloaded $ADD_BY_POINTER 3 4]
check "Overload by int" 110 [call_overloaded 10 5 6]

# Overloaded on a member pointer and a pointer, only the pointer taking NULL
set f [new_Funktions]
check "Overload by member pointer" 3 [memberpt_or_pointer $ADD_BY_VALUE]
check "Overload by pointer" 10 [memberpt_or_pointer $f]
check "Overload by NULL" 20 [memberpt_or_pointer NULL]

# An object pointer is not a member pointer
check_type_error "do_op with a Funktions pointer" { do_op $s $f }
delete_Funktions $f
