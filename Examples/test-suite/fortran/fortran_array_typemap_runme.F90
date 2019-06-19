! File : fortran_array_typemap_runme.f90

#include "fassert.h"

program fortran_array_typemap_runme
  use ISO_C_BINDING
  implicit none

  call test_ptr_size
  call test_fixed

contains

! Test two-argument (pointer + size) -> dynamic
subroutine test_ptr_size
  use fortran_array_typemap
  use ISO_C_BINDING
  implicit none
  real(C_DOUBLE), dimension(10) :: dbl_values
  integer(C_INT), dimension(4)  :: int_values

  call set_values_dbl(dbl_values, 4.25d0)
  call set_values_int(int_values, 2)

  ASSERT(all(int_values == 2))
  ASSERT(all(dbl_values == 4.25d0))
  ASSERT(accum(int_values) == 2 * 4)
end subroutine

! Test two-argument (pointer + size) -> dynamic
subroutine test_fixed
  use fortran_array_typemap
  use ISO_C_BINDING
  implicit none
  real(C_DOUBLE), dimension(2,3) :: dbl_values
  integer(C_INT), dimension(4)  :: int_values = [1,2,3,4]
  integer :: i, j

  call set_global(int_values)
  int_values(:) = 0
  int_values = get_global()

  do i = 1, 4
    ASSERT(int_values(i) == i)
  end do

  do j = 1,2
    do i = 1,3
      dbl_values(j,i) = real(i + 10 * j, C_DOUBLE)
    end do
  end do

  write(0,*) "dbl_values:", dbl_values
  write(0,*) "cpp_sum(dbl_values):", cpp_sum(dbl_values)
  ASSERT(cpp_sum(dbl_values) == sum(dbl_values))
end subroutine

end program


