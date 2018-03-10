program test_callback
  use cbext
  use callback
  implicit none

  call printcrap

  call test_procptr()
  call test_transform()
  call test_cb()

contains

! Fortran callback test
subroutine test_procptr
  use cbext
  implicit none
  procedure(fp_transform), pointer :: trans => null()

  write(*,*) "test_procptr"

  trans => enquote_single
  write(*,*) "Result: " // trans("whee")
  trans => bracket
  write(*,*) "Result: " // trans("whee")
end subroutine

! Actual C++ callback function test
subroutine test_transform
  use callback
  use, intrinsic :: ISO_C_BINDING
  implicit none
  character(kind=C_CHAR, len=:), allocatable :: str 

  write(*,*) "test_transform"

  str = join_transformed(", and ", enquote_cb)
  write(0,*) "Got string: " // str
end subroutine

! Actual C++ callback to wrapped Function procedure
subroutine test_cb
  use cbext
  use callback
  use, intrinsic :: ISO_C_BINDING
  implicit none
  character(kind=C_CHAR, len=:), allocatable :: str 

  write(*,*) "test_cb"

  ! Choose the internal Fortran procedure to wrap
  fortran_procptr => enquote_single
  ! Set C callback to our interface function (only needs to be done once)
  fortran_cb = c_funloc(swigc_fp_transform)

  str = join_transformed(", and ", director_cb)
  write(0,*) "Got string: " // str

  ! Choose the internal Fortran procedure to wrap
  fortran_procptr => bracket

  str = join_transformed(", and ", director_cb)
  write(0,*) "Got string: " // str
end subroutine 
 
end program
! vim: set ts=2 sw=2 sts=2 tw=79 :
