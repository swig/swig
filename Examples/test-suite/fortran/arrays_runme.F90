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
  type(SWIGTYPE_p_int) :: got_arr
  arr = ArrayStruct()
  call arr%set_array_i(array_to_ptr(actual))

  got_arr = arr%get_array_i()
  ASSERT(get_value(got_arr, 1) == actual(1))
  ASSERT(get_value(got_arr, 2) == actual(2))

end subroutine
end program

