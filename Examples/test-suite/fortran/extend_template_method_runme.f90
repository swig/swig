! File : extend_template_method_runme.f90

program extend_template_method_runme
  use extend_template_method
  use ISO_C_BINDING
  implicit none
  type(ExtendMe) :: em
  real(C_DOUBLE) :: ret_double

  em = create_ExtendMe()
  ret_double = em%do_stuff_double(1, 1.1d0)
  if (ret_double /= 1.1d0) stop 1

end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
