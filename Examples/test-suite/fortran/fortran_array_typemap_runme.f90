! File : fortran_array_typemap_runme.f90

program fortran_array_typemap_runme
  use fortran_array_typemap
  use ISO_C_BINDING
  implicit none
  real(C_DOUBLE), dimension(10) :: dbl_values
  integer(C_INT), dimension(4)  :: int_values

  call set_values_dbl(dbl_values, 4.25d0)
  call set_values_int(int_values, 2)

  if (any(int_values /= 2)) stop 1
  if (any(dbl_values /= 4.25d0)) stop 1
  if (accum(int_values) /= 2 * 4) stop 1
end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
