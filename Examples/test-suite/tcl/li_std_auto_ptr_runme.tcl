
if [ catch { load ./li_std_auto_ptr[info sharedlibextension] li_std_auto_ptr} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}


proc checkCount {expected_count} {
  set actual_count [Klass_getTotal_count]
  if {$actual_count != $expected_count} {
    error "Counts incorrect, expected: $expected_count actual: $actual_count"
  }
}

################################# Tcl pointer recycling bug start
# Not copied from cpp11_std_unique_ptr_runme.tcl
################################# Tcl pointer recycling bug end


# auto_ptr as input
Klass kin "KlassInput"
checkCount 1
set s [takeKlassAutoPtr kin]
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
set s [takeKlassAutoPtr kin]
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
if [ catch { set s [takeKlassAutoPtr kin] } e ] {
  if {[string first "cannot release ownership as memory is not owned" $e] == -1} {
    error "incorrect exception message: $e"
  }
  set exception_thrown 1
}
if {!$exception_thrown} {
  error "double usage of takeKlassAutoPtr should have been an error"
}
kin -delete # Should not fail, even though already deleted
checkCount 0

Klass kin "KlassInput"
set exception_thrown 0
set notowned [get_not_owned_ptr kin]
if [ catch {
  takeKlassAutoPtr notowned
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
set s [takeKlassAutoPtr kini]
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

# auto_ptr as output
set k1 [makeKlassAutoPtr "first"]
set k2 [makeKlassAutoPtr "second"]
if {[Klass_getTotal_count] != 2} {
  error "number of objects should be 2"
}

$k1 -delete
if {[Klass_getTotal_count] != 1} {
  error "number of objects should be 1"
}

if {[$k2 getLabel] != "second"} {
  error "wrong object label"
}

$k2 -delete
if {[Klass_getTotal_count] != 0} {
  error "no objects should be left"
}
