! File : abstract_access_runme.f90

program abstract_access_runme
  use abstract_access
  use ISO_C_BINDING
  implicit none
  type(D), target :: dcls
  class(A), pointer :: basecls => NULL()
  dcls = D()
  basecls => dcls

  if (basecls%do_x() /= 1) stop 1
end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
