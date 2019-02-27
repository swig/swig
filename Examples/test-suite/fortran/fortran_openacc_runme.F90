! File : fortran_openacc_runme.F90

#include "fassert.h"

program fortran_openacc_runme
  implicit none

  call test_openacc

contains
subroutine test_openacc
  use fortran_openacc
  use ISO_C_BINDING
  implicit none
  integer(C_INT), dimension(:), allocatable :: arr
  integer(C_INT) :: actual 

  allocate(arr(4), source = [1, 2, 3, 4])

  actual = thrust_accumulate(arr)
  ASSERT(actual == sum(arr))

end subroutine
end program
