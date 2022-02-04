! File : li_std_string_runme.f90

#include "fassert.h"

program li_std_string_runme
  use li_std_string
  use ISO_C_BINDING
  implicit none
  character(kind=C_CHAR, len=*), parameter :: mystring = "howdy!"
  character(kind=C_CHAR, len=:), allocatable :: actual
  type(swigtype_p_std__string) :: anonymous_string

  allocate(actual, source=test_value(mystring))
  ASSERT(actual == mystring)
  deallocate(actual)

  actual = test_const_reference(mystring)
  ASSERT(actual == mystring)
  deallocate(actual)

  call test_pointer(anonymous_string)

  anonymous_string = test_pointer_out()
end program

