
program test_callback
  implicit none
  call test_all()
contains
subroutine test_all
  use callback
  use, intrinsic :: ISO_C_BINDING
  implicit none
  character(kind=C_CHAR, len=:), allocatable :: str 

  str = join_transformed(", and ", enquote_cb)
  write(0,*) "Got string: " // str
end subroutine

end program
! vim: set ts=2 sw=2 sts=2 tw=129 :
