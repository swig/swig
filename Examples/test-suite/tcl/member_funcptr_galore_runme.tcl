if [ catch { load ./member_funcptr_galore[info sharedlibextension] Member_funcptr_galore} err_msg ] {
    puts stderr "Could not load shared object:\n$err_msg"
    exit 1
}

proc check_type_error {what script} {
    if {![catch {uplevel 1 $script} err_msg]} { error "$what accepted" }
    if {![string match "*TypeError*" $err_msg]} { error "$what: $err_msg" }
}

MemberFuncPtrs m
if {[m aaa1 $cc1] != 0} { error "aaa1" }
if {[m aaa6 $cc6] != 0} { error "aaa6" }
if {[m aaa7 $cc7] != 0} { error "aaa7" }
if {[m bbb1 $pp1] != 0} { error "bbb1" }
if {[m bbb6 $pp6] != 0} { error "bbb6" }
if {[m bbb7 $pp7] != 0} { error "bbb7" }
if {[call1 $ADD_BY_VALUE 1 2] != 3} { error "call1" }

# A const reference to a member pointer is passed and returned as the member pointer
if {[m aaa7 $cc1] != 0} { error "aaa7 with cc1" }
if {[m aaa1 $cc7] != 0} { error "aaa1 with cc7" }

# A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
check_type_error "aaa1 with pp1" { m aaa1 $pp1 }
check_type_error "aaa7 with pp7" { m aaa7 $pp7 }
check_type_error "bbb1 with cc1" { m bbb1 $cc1 }
check_type_error "bbb7 with cc7" { m bbb7 $cc7 }
