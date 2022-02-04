! File : runme.f90

program main
  use, intrinsic :: ISO_C_BINDING
  use example, only : print_str, halved_str, reversed_str
  use ISO_FORTRAN_ENV
  implicit none
  integer, parameter :: STDOUT = OUTPUT_UNIT
  character(len=*), parameter :: paramstr = "short string   "
  character(len=*), parameter :: sampletext = "Through the looking glass"
  character(len=:), allocatable :: tempstr
  character(len=16) :: fixedlen

  write(STDOUT, *) "Print parameter string:"
  call print_str(trim(paramstr))

  write(STDOUT, *) "Print trimmed parameter string:"
  call print_str(trim(paramstr))

  write(STDOUT, *) "Print inline string:"
  call print_str("fixed")

  fixedlen = "01234567" // c_null_char// "9abcdef"
  write(STDOUT, *) "Fixed-length string with embedded null: '"//fixedlen//"'"
  call print_str(fixedlen)

  ! Cut it in half and read it back out to varlen
  tempstr = "Tacocat tacocat!"
  write(STDOUT, *) "Halving..."
  tempstr = halved_str(tempstr)

  write(STDOUT, *) "Halved: '" // tempstr // "' (len=", len(tempstr), ")"

  tempstr = halved_str(tempstr)
  write(STDOUT, *) "Quarter-length string: '"//tempstr//"'"

  write(STDOUT, *) "Reversing"
  tempstr = sampletext
  tempstr = reversed_str(tempstr)

  write(STDOUT, *) "'"//sampletext//"' -> '"//tempstr//"'"
end program


!-----------------------------------------------------------------------------!
! end of example/runme.f90
!-----------------------------------------------------------------------------!

