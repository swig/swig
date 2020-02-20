! File : fortran_naming_runme.F90

#include "fassert.h"

program fortran_naming_runme
  use fortran_naming
  use ISO_C_BINDING
  implicit none
  integer(C_INT) :: test_int
  type(Foo_) :: myfoo
  type(MyStruct) :: struct
  type(SWIGTYPE_p_OpaqueStruct) :: opaque
  type(SWIGTYPE_p_p_OpaqueStruct) :: opaque_handle
  type(SWIGTYPE_p_DeclaredStruct) :: declared
  type(SWIGTYPE_p_IgnoredStruct) :: ignored
  type(SWIGTYPE_p_TemplatedStructT_int_t) :: templated

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

  opaque = make_opaque_value(123)
  ASSERT(get_opaque_value(opaque) == 123)
  opaque = get_opaque_ptr(opaque)
  ASSERT(get_opaque_value(opaque) == 123)
  opaque = get_opaque_ref(opaque)
  ASSERT(get_opaque_value(opaque) == 123)
  opaque = get_opaque_cptr(opaque)
  ASSERT(get_opaque_value(opaque) == 123)
  opaque = get_opaque_cref(opaque)
  ASSERT(get_opaque_value(opaque) == 123)

  opaque_handle = get_opaque_handle()

  ASSERT(f_123 == 123)

  declared = make_declared(254)
  ASSERT(get_declared_value(declared) == 254)

  ! This will NOT work because of type safety for the unknown types
  ! ASSERT(get_opaque_value(declared) == 254)

  ignored = make_ignored(979)
  ASSERT(get_ignored_value(ignored) == 979)

  templated = make_templated(409)
  ASSERT(get_templated_value(templated) == 409)

  ! Check renamed long words
  ASSERT(sixty_four_characters_is_way_too_long_for_fortran_or_punc11LMB6 == 64)
  ASSERT(sixty_four_characters_is_way_too_long_for_fortran_or_punchXAJBV == 65)
  ASSERT(leading_underscore_with_sixty_four_characters_is_just_darnIR2OS == 64)
  ASSERT(leading_underscore_with_sixty_three_characters_might_be_tricky_ == 63)
  ASSERT(this_is_a_very_long_name_but_its_ok_unless_its_overloaded() == 0)
  ASSERT(this_is_a_very_long_name_but_its_bad_since_its_overloaded(10) == 10)
  ASSERT(this_is_a_very_long_name_but_its_bad_since_its_overloaded(20.0) == 20.0)

  ! Check elided enum
  ASSERT(Zero == 0)
  ASSERT(Two == 2)

  ASSERT(AlsoZero == 0)
  ASSERT(AlsoTwo == 2)

end program


