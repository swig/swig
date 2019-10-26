! File : extend_template_method_runme.F90

#include "fassert.h"

program extend_template_method_runme
  use extend_template_method
  use ISO_C_BINDING
  implicit none
  type(ExtendMe) :: em
  type(TemplateExtend) :: tm
  real(C_DOUBLE) :: dbl
  character(len=:), allocatable :: str

  em = ExtendMe()
  dbl = em%do_stuff_double(1, 1.1d0)
  ASSERT(dbl == 1.1d0)
  str = em%do_stuff_string(1, "hello there")
  ASSERT(str == "hello there")

  dbl = em%do_overloaded_stuff(1.1d0)
  ASSERT(dbl == 1.1d0)
  str = em%do_overloaded_stuff("hello there")
  ASSERT(str == "hello there")

  call em%release()

  ! Static method works on unreleased em
  ASSERT(em%static_method(123) == 123)

  tm = TemplateExtend()
  dbl = tm%do_template_stuff_double(1, 1.1d0)
  ASSERT(dbl == 1.1d0)
  str = tm%do_template_stuff_string(1, "hello there")
  ASSERT(str == "hello there")

  dbl = tm%do_template_overloaded_stuff(1.1d0)
  ASSERT(dbl == 1.1d0)
  str = tm%do_template_overloaded_stuff("hello there")
  ASSERT(str == "hello there")

  call tm%release()

  ! Static method works on unreleased em
  ASSERT(tm%static_template_method(123) == 123)

  tm = TemplateExtend(123)

end program


