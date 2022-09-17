
if [ catch { load ./cpp11_rvalue_reference_move[info sharedlibextension] cpp11_rvalue_reference_move} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}


# Function containing rvalue reference parameter
Counter_reset_counts
MovableCopyable mo 222
Counter_check_counts 1  0  0  0  0  0
MovableCopyable_movein mo
Counter_check_counts 1  0  0  1  0  2
if {![MovableCopyable_is_nullptr mo]} {
  error "is_nullptr failed to throw"
}
mo -delete
Counter_check_counts 1  0  0  1  0  2

# Move constructor test
Counter_reset_counts
MovableCopyable mo 222
Counter_check_counts 1  0  0  0  0  0
MovableCopyable mo_moved mo
Counter_check_counts 1  0  0  1  0  1
if {![MovableCopyable_is_nullptr mo]} {
  error "is_nullptr failed to throw"
}
mo -delete
Counter_check_counts 1  0  0  1  0  1
mo_moved -delete
Counter_check_counts 1  0  0  1  0  2

# Move assignment operator test
Counter_reset_counts
MovableCopyable mo111 111
MovableCopyable mo222 222
Counter_check_counts 2  0  0  0  0  0
mo111 MoveAssign mo222
Counter_check_counts 2  0  0  0  1  1
if {![MovableCopyable_is_nullptr mo222]} {
  error "is_nullptr failed to throw"
}
mo222 -delete
Counter_check_counts 2  0  0  0  1  1
mo111 -delete
Counter_check_counts 2  0  0  0  1  2

# null check
Counter_reset_counts
set exception_thrown 0
if [ catch {
  MovableCopyable_movein "NULL"
} e ] {
  if {[string first "invalid null reference" $e] == -1} {
    error "incorrect exception message: $e"
  }
  set exception_thrown 1
}
if {!$exception_thrown} {
  error "Should have thrown null error"
}
Counter_check_counts 0  0  0  0  0  0

# output
Counter_reset_counts
set mc [MovableCopyable_moveout 1234]
Counter_check_counts  2  0  0  0  1  1
MovableCopyable_check_numbers_match $mc 1234

set exception_thrown 0
if [ catch {
  MovableCopyable_movein $mc
} e ] {
  if {[string first "cannot release ownership as memory is not owned" $e] == -1} {
    error "incorrect exception message: $e"
  }
  set exception_thrown 1
}
if {!$exception_thrown} {
  error "Should have thrown 'Cannot release ownership as memory is not owned' error"
}
Counter_check_counts  2  0  0  0  1  1
