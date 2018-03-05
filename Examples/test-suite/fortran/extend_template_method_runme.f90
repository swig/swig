! File : extend_template_method_runme.f90

program extend_template_method_runme
  use extend_template_method
  use ISO_C_BINDING
  implicit none
  type(ExtendMe) :: em
  type(TemplateExtend) :: tm
  real(C_DOUBLE) :: dbl
  character(kind=C_CHAR, len=:), allocatable :: str

  em = ExtendMe()
  dbl = em%do_stuff_double(1, 1.1d0)
  if (dbl /= 1.1d0) stop 1
  str = em%do_stuff_string(1, "hello there")
  if (str /= "hello there") stop 1

  dbl = em%do_overloaded_stuff(1.1d0)
  if (dbl /= 1.1d0) stop 1
  str = em%do_overloaded_stuff("hello there")
  if (str /= "hello there") stop 1

  call em%release()

  ! Static method works on unreleased em
  if (em%static_method(123) /= 123) stop 1

  tm = TemplateExtend()
  dbl = tm%do_template_stuff_double(1, 1.1d0)
  if (dbl /= 1.1d0) stop 1
  str = tm%do_template_stuff_string(1, "hello there")
  if (str /= "hello there") stop 1

  dbl = tm%do_template_overloaded_stuff(1.1d0)
  if (dbl /= 1.1d0) stop 1
  str = tm%do_template_overloaded_stuff("hello there")
  if (str /= "hello there") stop 1

  call tm%release()

  ! Static method works on unreleased em
  if (tm%static_template_method(123) /= 123) stop 1

  tm = TemplateExtend(123)

end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
