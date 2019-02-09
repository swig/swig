! File : arrays_runme.F90

#include "fassert.h"

program arrays_runme
  implicit none

  call test_arrays

contains
subroutine test_arrays
  use arrays
  use ISO_C_BINDING
  implicit none
  type(ArrayStruct) :: arr
  integer(C_INT), dimension(2) :: actual = [ 91, 420 ]
  integer(C_INT), dimension(:), pointer :: got_arr
  arr = ArrayStruct()
  call arr%set_array_i(actual)

  got_arr => arr%get_array_i()
  write(0,*) got_arr

  if (any(got_arr /= actual)) stop 1

end subroutine
end program

