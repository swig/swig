! File : fortran_naming_runme.F90

#include "fassert.h"

program fortran_naming_runme
  use fortran_naming
  use ISO_C_BINDING
  implicit none
  integer(C_INT) :: test_int
  type(Foo_) :: myfoo
  type(MyStruct) :: struct
  type(SWIGTYPE_OpaqueStruct) :: opaque
  type(SWIGTYPE_DeclaredStruct) :: declared

  myfoo = Foo_()
  call myfoo%release()

  ! NOTE: the 'C' function that's bound is actually named _cboundfunc, so this
  ! will cause a link error if broken
  test_int = 3
  ASSERT(cboundfunc_0(test_int) == (3 + 1)) 

  ! The member variable has been renamed, but the layout should be the same
  struct%m_y = 4
  ASSERT(get_mystruct_y(struct) == 4) 

  ! The first enum _MYVAL should have priority over the later ones
  ASSERT(MYVAL_ == 1) 

  opaque = make_opaque(123)
  ASSERT(get_opaque_value(opaque) == 123)

  ASSERT(f_123 == 123)

  declared = make_declared(254)
  ASSERT(get_declared_value(declared) == 254)

  ! This will NOT work because of type safety for the unknown types
  ! ASSERT(get_opaque_value(declared) == 254)

  ! Check renamed long words
  ASSERT(sixty_four_characters_is_way_too_long_for_fortran_or_punc11LMB6 == 64)
  ASSERT(sixty_four_characters_is_way_too_long_for_fortran_or_punchXAJBV == 65)
  ASSERT(leading_underscore_with_sixty_four_characters_is_just_darnIR2OS == 64)
  ASSERT(leading_underscore_with_sixty_three_characters_might_be_tricky_ == 63)

end program


