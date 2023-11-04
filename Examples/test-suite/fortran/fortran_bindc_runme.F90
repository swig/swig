! File : fortran_bindc_runme.F90

#include "fassert.h"

program fortran_bindc_runme
  implicit none

  call test_globals
  call test_arrays
  call test_twod_unknown_int
  call test_fundamental
  call test_opaque_struct
  call test_strings

contains

! Test global data
subroutine test_globals
  use fortran_bindc
  use ISO_C_BINDING
  implicit none

  ASSERT(my_const_global_int == 9)
  ! Uncommenting the following line should cause a compile error
  ! my_const_global_int = 4

  my_global_int = 4567
  ASSERT(my_global_int == 4567)
  ASSERT(get_my_global_int_from_c() == 4567)

end subroutine

! Test arrays of bound structs and classes
subroutine test_arrays
  use fortran_bindc
  use ISO_C_BINDING
  implicit none
  type(XYArray) :: xyarr
  type(XY) :: tempxy
  integer :: i
  integer(c_short) :: short_array(5) = [ 5_c_short, 40_c_short, 300_c_short, 2000_c_short, 10000_c_short ]
  integer(c_short) :: summed

  ! Allocate a new C array
  xyarr = XYArray(3);
  do i = 1,3
    tempxy%x = 10 * i
    tempxy%y = 10 * i + 1
    call xyarr%setitem(i - 1, tempxy)
  end do

  ! Sum a fortran array using a bound(C) function
  summed = sum_array(short_array)
  ASSERT(summed == 12345)

end subroutine

subroutine test_twod_unknown_int
  use fortran_bindc
  use ISO_C_BINDING
  implicit none
  integer(C_INT), target :: test_data(10, 3)
  integer(C_INT) :: i, j, nerrs

  test_data(:,:) = -1
  call twod_unknown_int(test_data, size(test_data, 2))

  nerrs = 0
  do i = 1,10
    do j = 1,3
      if (test_data(i,j) /= i + 10*(j-1)) nerrs = nerrs + 1
    end do
  end do

  if (nerrs /= 0) then
    write(*,*) nerrs, " bad entries:"
    write(*,*) test_data
    stop 1
  end if
end subroutine

subroutine test_fundamental
  use fortran_bindc
  use ISO_C_BINDING
  implicit none
  real(C_FLOAT) :: x(10), y(10)
  integer :: i

  do i = 1, 10
    x(i) = real(i)
    y(i) = 100.0
  end do

  call saxpy(10_c_int, 2.5, x(1), y(1))

end subroutine

subroutine test_opaque_struct
  use fortran_bindc
  use ISO_C_BINDING
  implicit none
  type(C_PTR) :: s

  s = make_intstruct(1234_c_int)
  ASSERT(1234_c_int == get_instruct_i(s))

end subroutine

subroutine test_strings
  use fortran_bindc
  use ISO_C_BINDING
  implicit none
  character(kind=c_char, len=*), parameter :: mystring = "I'm a string!"
#if __GNUC__ >= 9
  type(C_PTR) :: cptr
  character(kind=c_char, len=:), pointer :: cstrptr
#endif

  ASSERT(strlen(mystring // C_NULL_CHAR) == len(mystring))

#if __GNUC__ >= 9
  ! Note: this seems to be allowed in GCC 9 but not before. I'm not sure that it's the correct behavior.
  cptr = getstr(1)
  call c_f_pointer(cptr, cstrptr)
  ASSERT(associated(cstrptr))
  ASSERT(strlen(cstrptr) == 3)
  ASSERT(cstrptr(1:3) == "one")
#endif

end subroutine

end program

