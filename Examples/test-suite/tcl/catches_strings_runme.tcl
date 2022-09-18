
if [ catch { load ./catches_strings[info sharedlibextension] catches_strings} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}


set exception_thrown 0
if [ catch {
  StringsThrower_charstring
} e ] {
  if {[string first "charstring message" $e] == -1} {
    error "incorrect exception message: $e"
  }
  set exception_thrown 1
}
if {!$exception_thrown} {
  error "Should have thrown an exception"
}

set exception_thrown 0
if [ catch {
  StringsThrower_stdstring
} e ] {
  if {[string first "stdstring message" $e] == -1} {
    error "incorrect exception message: $e"
  }
  set exception_thrown 1
}
if {!$exception_thrown} {
  error "Should have thrown an exception"
}
