! File : cpp11_std_unique_ptr_runme.F90

#include "fassert.h"

program cpp11_std_unique_ptr_runme
  implicit none

  call test_raw

contains
subroutine test_raw
  use cpp11_std_unique_ptr
  use ISO_C_BINDING
  implicit none
  type(Klass) :: k
  type(KlassInheritance) :: kini
  character(kind=C_CHAR, len=:), allocatable :: s

  ASSERT(k%getTotal_count() == 0)
  ASSERT(is_nullptr(kini))
  kini = KlassInheritance("KlassInheritanceInput")
  ASSERT(k%getTotal_count() == 1)
  ! FIXME: virtual inheritance doesn't work in fortran wrappers
  ! ASSERT(kini%getLabel() == "KlassInheritanceInput")
  ! s = useKlassRawPtr(kini)
  ! ASSERT(s == "KlassInheritanceInput")
  ! call kini%release()
  ASSERT(c_associated(kini%swigdata%cptr))
  ASSERT(.not. is_nullptr(kini))
  kini = makeNullUniquePtr()
  ASSERT(k%getTotal_count() == 0)
  ASSERT(.not. c_associated(kini%swigdata%cptr))
  ASSERT(is_nullptr(kini))

  kini = make_null()
  ASSERT(.not. c_associated(kini%swigdata%cptr))

end subroutine
end program

