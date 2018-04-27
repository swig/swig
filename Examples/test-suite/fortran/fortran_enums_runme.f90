! File : fortran_enums_runme.f90

program fortran_enums_runme
  use fortran_enums
  use ISO_C_BINDING
  implicit none
  integer :: my_array(Charlie) ! OK because Charlie has constant shaope
  integer :: enum_name_array(NativeEnum + 4) ! OK: NativeEnum is parameter
  ! integer :: cannot_do_this(Foxtrot) ! ERROR: Foxtrot is externally defined

  if (size(my_array) /= 2) stop 1
  if (size(enum_name_array) /= 3) stop 1
  if (Foxtrot /= 12345) stop 1
  ! Foxtrot = 2 ! ERROR: Foxtrot is PROTECTED
end program


