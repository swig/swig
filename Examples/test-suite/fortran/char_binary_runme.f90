! File : char_binary_runme.f90

program char_binary_runme
  use char_binary
  use ISO_C_BINDING
  implicit none
  character(kind=C_CHAR, len=*), parameter :: withnull = "hil" // C_NULL_CHAR
  type(Test) :: t

  if (len(withnull) /= 4) stop 2

  t = create_Test()
  if (t%strlen("hile") /= 4) stop 1
  if (t%ustrlen("hile") /= 4) stop 1

  if (t%strlen(withnull) /= 4) stop 1
  if (t%ustrlen(withnull) /= 4) stop 1

end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
