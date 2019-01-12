! File : default_args_runme.F90

#include "fassert.h"

program default_args_runme
  use default_args
  use ISO_C_BINDING
  implicit none
  type(EnumClass) :: ec
  type(DerivedEnumClass) :: de
  type(Statics) :: s

  ec = EnumClass()
  if (ec%blah() .neqv. .true.) stop 1
  ASSERT(chartest1() == 'x')
  ASSERT(chartest2() == c_null_char)
  ASSERT(s%staticmethod() == 60)

  ! casts1 will return a null char pointer; on GCC at least `c_f_pointer` converts it to a Fortran null pointer, but 
  ! the standard DOES NOT guarantee it becomes a disassociated pointer
  ! if (associated(casts1())) stop 1

  de = DerivedEnumClass()
  call de%accelerate()
  call de%accelerate(EnumClass_SLOW)

end program

