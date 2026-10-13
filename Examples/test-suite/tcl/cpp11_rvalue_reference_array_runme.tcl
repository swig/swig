if [ catch { load ./cpp11_rvalue_reference_array[info sharedlibextension] Cpp11_rvalue_reference_array} err ] {
    puts stderr "Could not load shared object:\n$err"
    exit 1
}

proc check_null_rejected {what script} {
    if {![catch {uplevel 1 $script}]} { error "$what accepted NULL" }
}

# An rvalue reference to an array is passed as a reference to an array, which cannot be NULL.
if {[sum_of [others_address]] != 100} { error "sum_of" }
if {[first_of [others_unsized_address]] != 10} { error "first_of" }
if {[items_sum [items_address]] != 3} { error "items_sum" }
check_null_rejected "sum_of" { sum_of NULL }
check_null_rejected "first_of" { first_of NULL }

# An rvalue reference to an array of char is a string.
if {[length_of "abc"] != 3} { error "length_of" }
if {[length_of_writable "xy"] != 2} { error "length_of_writable" }

# Setting a variable that is an rvalue reference to an array copies into the array it refers to.
if {[numbers_sum] != 10} { error "numbers_sum" }
set numbers_rref $others
if {[numbers_sum] != 100} { error "numbers_sum after set" }
if {$letters_rref != "abc"} { error "letters_rref" }
set letters_rref "xy"
if {[letters_are] != "xy"} { error "letters_are" }

RvalueRefArrayMember member
if {[member sum] != 10} { error "member sum" }
member configure -member_rref [others_address]
if {[member sum] != 100} { error "member sum after set" }
if {[member cget -text_rref] != "hi"} { error "member text_rref" }
member configure -text_rref "bye"
if {[member text_is] != "bye"} { error "member text_is" }
