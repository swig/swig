if [ catch { load ./arrays_null[info sharedlibextension] Arrays_null} err ] {
    puts stderr "Could not load shared object:\n$err"
    exit 1
}

proc check_null_rejected {what script} {
    if {![catch {uplevel 1 $script}]} { error "$what set to NULL accepted" }
}

ArraysNull s
ArraysNull other
arrays_null_fill other 10
s configure -ints [other cget -ints]
s configure -items [other cget -items]
s configure -grid [other cget -grid]
if {[arrays_null_check s 10] != 1} { error "member set" }

# Setting an array member or global variable to NULL is an error, as there is nothing to copy from.
check_null_rejected "ints member" { s configure -ints NULL }
check_null_rejected "items member" { s configure -items NULL }
check_null_rejected "grid member" { s configure -grid NULL }
if {[arrays_null_check s 10] != 1} { error "member set to NULL changed it" }

set arrays_null_ints [s cget -ints]
set arrays_null_items [s cget -items]
set arrays_null_grid [s cget -grid]
if {[arrays_null_globals_check 10] != 1} { error "global set" }

check_null_rejected "ints global" { set arrays_null_ints NULL }
check_null_rejected "items global" { set arrays_null_items NULL }
check_null_rejected "grid global" { set arrays_null_grid NULL }
check_null_rejected "ints_ref global" { set arrays_null_ints_ref NULL }
if {[arrays_null_globals_check 10] != 1} { error "global set to NULL changed it" }

# NULL is passed on as a NULL pointer for an array parameter.
if {[arrays_null_isnull NULL] != 1} { error "ints parameter" }
