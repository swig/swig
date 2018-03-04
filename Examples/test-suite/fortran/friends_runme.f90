! File : friends_runme.f90

program friends_runme
  use friends
  use ISO_C_BINDING
  implicit none
  type(A) :: ai
  type(B) :: bi
  type(D_i) :: di
  type(D_d) :: dd

  ai = create_A(2)
  if (get_val1(ai) /= 2) stop 1
  if (get_val2(ai) /= 4) stop 1
  if (get_val3(ai) /= 6) stop 1

  ! nice overload working fine
  if (get_val1(1,2,3) /= 1) stop 1

  bi = create_B(3)

  ! david's case
  if (mix(ai,bi) /= 5) stop 1

  di = create_D_i(2)
  dd = create_D_d(3.3d0)

  if (get_val1(di) /= 2) stop 1
  if (get_val1(dd) /= 3.3d0) stop 1

  call set(di, 4)
  call set(dd, 1.3d0)

  if (get_val1(di) /= 4) stop 1
  if (get_val1(dd) /= 1.3d0) stop 1

end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
