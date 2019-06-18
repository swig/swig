! File : arrays_global_twodim.F90

#include "fassert.h"

program arrays_global_twodim
  use ISO_C_BINDING
  implicit none

  call test_int_array
contains

subroutine test_int_array  
  use arrays_global_twodim
  use ISO_C_BINDING
  implicit none
  ! The following will fail to build if they're not defined as PARAMETERS in the module file
  type(SWIGTYPE_p_a_4__int) :: constintarray2d
  type(SWIGTYPE_p_a_4__int) :: intarray2d
  integer(C_INT) :: cnt = 10
  integer(C_INT) :: x, y
  integer(C_INT), dimension(:,:), allocatable :: expected, actual

  constintarray2d = get_array_const_i()
  intarray2d = get_array_i()

  call set_array_i(constintarray2d)

  allocate(expected(ARRAY_LEN_Y, ARRAY_LEN_X))
  allocate(actual(ARRAY_LEN_Y, ARRAY_LEN_X))

  do x = 1, ARRAY_LEN_X
    do y = 1, ARRAY_LEN_Y
      expected(y, x) = cnt
      cnt = cnt + 1
      actual(y, x) = get_2d_array(intarray2d, x - 1, y - 1)
    end do
  end do

  write(*,*) "Expected:", expected
  write(*,*) "Actual:", actual
  ASSERT(all(expected == actual))
end subroutine
end program


