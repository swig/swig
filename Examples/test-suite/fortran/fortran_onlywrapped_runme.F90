! File : fortran_onlywrapped_runme.F90

#include "fassert.h"

program fortran_onlywrapped_runme
  use fortran_onlywrapped
  use ISO_C_BINDING
  implicit none
  type(SWIGTYPE_p_Unloved) :: blah
  type(Normal) :: norm

  blah = should_be_wrapped()

  call overloaded(norm)
  call overloaded(123)

end program

