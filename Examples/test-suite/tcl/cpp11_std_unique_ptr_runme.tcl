
if [ catch { load ./cpp11_std_unique_ptr[info sharedlibextension] cpp11_std_unique_ptr} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}


proc checkCount {expected_count} {
  set actual_count [Klass_getTotal_count]
  if {$actual_count != $expected_count} {
    error "Counts incorrect, expected: $expected_count actual: $actual_count"
  }
}

################################# Tcl pointer recycling bug start
#
# ### Possibly related to premature object deletion problem mentioned in newobject1_runme.tcl. ###
#
# While this won't be repeatable on all machines, the following caused the underlying C++
# pointer value for k1 to be reused for k4.
#
# If the C/C++ memory allocator uses the same pointer value again, then a command name that
# contains a pointer encoding, such as, _b09b1148bd550000_p_Klass (not a variable name) will be
# re-used in SWIG_Tcl_NewInstanceObj. The command should have disappeared from the Tcl side when
# the object was deleted, but there is some sort of bug preventing this from happening in this
# scenario as follows:
#
# Below creates a struct via the call to Tcl_CreateObjCommand in
# SWIG_Tcl_NewInstanceObj (creates a command name with a pointer encoding such as
# _50fb3608ce550000_p_Klass) which also makes a second call to Tcl_CreateObjCommand in
# SWIG_Tcl_ObjectConstructor (creates a command name with the name k1).
Klass k1 "one"
# Line below calls Tcl_DeleteCommandFromToken but is only called for the command created in the
# second call (k1) and not the first call to Tcl_CreateObjCommand.
k1 -delete
set k2 [makeKlassUniquePtr "two"]
set k3 [makeKlassUniquePtr "three"]
$k2 -delete
# If the memory allocator uses the same pointer value, then SWIG_Tcl_NewInstanceObj will find
# the undeleted command _50fb3608ce550000_p_Klass and re-use it. This command should surely
# have been deleted !??
set k4 [makeKlassUniquePtr "four"]
$k3 -delete
$k4 -delete
checkCount 0
################################# Tcl pointer recycling bug end

# Test raw pointer handling involving virtual inheritance
KlassInheritance kini "KlassInheritanceInput"
checkCount 1
set s [useKlassRawPtr kini]
kini -delete
checkCount 0


# unique_ptr as input
Klass kin "KlassInput"
checkCount 1
set s [takeKlassUniquePtr kin]
checkCount 0
if {[kin cget -thisown]} {
  error "thisown should be false"
}
if {$s != "KlassInput"} {
  error "Incorrect string: $s"
}
if {![is_nullptr kin]} {
  error "is_nullptr failed"
}
kin -delete # Should not fail, even though already deleted
checkCount 0

Klass kin "KlassInput"
checkCount 1
set s [takeKlassUniquePtr kin]
checkCount 0
if {[kin cget -thisown]} {
  error "thisown should be false"
}
if {$s != "KlassInput"} {
  error "Incorrect string: $s"
}
if {![is_nullptr kin]} {
  error "is_nullptr failed"
}
set exception_thrown 0
if [ catch { set s [takeKlassUniquePtr kin] } e ] {
  if {[string first "cannot release ownership as memory is not owned" $e] == -1} {
    error "incorrect exception message: $e"
  }
  set exception_thrown 1
}
if {!$exception_thrown} {
  error "double usage of takeKlassUniquePtr should have been an error"
}
kin -delete # Should not fail, even though already deleted
checkCount 0

Klass kin "KlassInput"
set exception_thrown 0
set notowned [get_not_owned_ptr kin]
if [ catch {
  takeKlassUniquePtr notowned
} ] {
  set exception_thrown 1
}
if {!$exception_thrown} {
  error "Should have thrown 'Cannot release ownership as memory is not owned' error"
}
checkCount 1
kin -delete
checkCount 0

KlassInheritance kini "KlassInheritanceInput"
checkCount 1
set s [takeKlassUniquePtr kini]
checkCount 0
if {[kini cget -thisown]} {
  error "thisown should be false"
}
if {$s != "KlassInheritanceInput"} {
  error "Incorrect string: $s"
}
if {![is_nullptr kini]} {
  error "is_nullptr failed"
}
kini -delete # Should not fail, even though already deleted
checkCount 0

takeKlassUniquePtr "NULL"
takeKlassUniquePtr [make_null]
checkCount 0

# overloaded parameters
if {[overloadTest] != 0} {
  error "overloadTest failed"
}
if {[overloadTest "NULL"] != 1} {
  error "overloadTest failed"
}
if {[overloadTest [Klass k "over"]] != 1} {
  error "overloadTest failed"
}
checkCount 0


# unique_ptr as output
set k1 [makeKlassUniquePtr "first"]
set k2 [makeKlassUniquePtr "second"]
checkCount 2

$k1 -delete
checkCount 1

if {[$k2 getLabel] != "second"} {
  error "wrong object label"
}

$k2 -delete
checkCount 0

if {[makeNullUniquePtr] != "NULL"} {
  error "null failure"
}
