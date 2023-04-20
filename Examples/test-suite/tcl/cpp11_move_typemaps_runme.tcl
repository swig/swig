
if [ catch { load ./cpp11_move_typemaps[info sharedlibextension] cpp11_move_typemaps} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

Counter_reset_counts
MoveOnly mo 111
Counter_check_counts 1 0 0 0 0 0
MoveOnly_take mo
Counter_check_counts 1 0 0 1 0 2
mo -delete
Counter_check_counts 1 0 0 1 0 2

Counter_reset_counts
MovableCopyable mo 111
Counter_check_counts 1 0 0 0 0 0
MovableCopyable_take mo
Counter_check_counts 1 0 0 1 0 2
mo -delete
Counter_check_counts 1 0 0 1 0 2

MoveOnly mo 222
MoveOnly_take mo
set exception_thrown 0
if [ catch {
  MoveOnly_take mo
} e ] {
  if {[string first "cannot release ownership as memory is not owned" $e] == -1} {
    error "incorrect exception message: $e"
  }
  set exception_thrown 1
}
if {!$exception_thrown} {
  error "Should have thrown 'Cannot release ownership as memory is not owned' error"
}
