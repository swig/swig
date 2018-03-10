module my_transforms
  implicit none
contains
  function enquote_single(s) &
      result(news)
    use, intrinsic :: ISO_C_BINDING
    character(kind=C_CHAR, len=:), allocatable :: news
    character(kind=C_CHAR, len=*) :: s
    news = "'" // s // "'"
  end function

  function bracket(s) &
      result(news)
    use, intrinsic :: ISO_C_BINDING
    character(kind=C_CHAR, len=:), allocatable :: news
    character(kind=C_CHAR, len=*) :: s
    news = "[" // s // "]"
  end function
end module

program test_callback
  use callback
  implicit none

  call test_procptr()
  call test_transform()
  call test_cb()

contains

! Fortran callback test
subroutine test_procptr
  use my_transforms
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
  use my_transforms
  use callback
  use, intrinsic :: ISO_C_BINDING
  implicit none
  character(kind=C_CHAR, len=:), allocatable :: str 

  write(*,*) "test_cb"

  ! Choose the internal Fortran procedure to wrap
  fortran_procptr => enquote_single

  str = join_transformed(", and ", director_cb)
  write(0,*) "Got string: " // str

  ! Choose the internal Fortran procedure to wrap
  fortran_procptr => bracket

  str = join_transformed(", and ", director_cb)
  write(0,*) "Got string: " // str
end subroutine 
 
end program
! vim: set ts=2 sw=2 sts=2 tw=79 :
