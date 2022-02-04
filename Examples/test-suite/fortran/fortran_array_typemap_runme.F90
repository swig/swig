! File : fortran_array_typemap_runme.f90

#include "fassert.h"

program fortran_array_typemap_runme
  implicit none

  call test_ptr_size
  call test_fixed
  call test_deferred
  call test_deferred_2d

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

! Test hard-coded dimensions
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

  ASSERT(cpp_sum(dbl_values) == sum(dbl_values))
end subroutine

! Test deferred-size arrays
subroutine test_deferred
  use fortran_array_typemap
  use ISO_C_BINDING
  implicit none
  real(C_DOUBLE), dimension(5) :: dbl_values
  integer :: i

  dbl_values = [(i * 2.0d0, i = 1, size(dbl_values))]

  ASSERT(cpp_dynamic_sum(size(dbl_values), dbl_values) == sum(dbl_values))

end subroutine

! Test deferred-size arrays
subroutine test_deferred_2d
  use fortran_array_typemap
  use ISO_C_BINDING
  implicit none
  real(C_DOUBLE), dimension(3,2) :: points
  real(C_DOUBLE), dimension(3) :: avg_points = [-1, -1, -1]

  points(:,1) = [-10, 10, 4]
  points(:,2) = [10, 10, 0]
  call average_points(size(points, 2), points, avg_points)

  ASSERT(avg_points(1) == 0.0d0)
  ASSERT(avg_points(2) == 10.0d0)
  ASSERT(avg_points(3) == 2.0d0)

end subroutine

end program
