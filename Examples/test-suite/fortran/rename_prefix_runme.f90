! File : rename_prefix_runme.f90

program rename_prefix_runme
  use rename_prefix
  use ISO_C_BINDING
  implicit none

  call prefix_prea
  call myprefixnot
  call bada
  call badprefixnot
end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
