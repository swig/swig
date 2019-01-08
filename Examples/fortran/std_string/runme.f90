! File : runme.f90

program main
  use ISO_FORTRAN_ENV
  use, intrinsic :: ISO_C_BINDING
  use example, only : print_str, halved_str, reversed_str
  implicit none
  character(len=*), parameter :: paramstr = "short string   "
  character(len=*), parameter :: sampletext = "Through the looking glass"
  character(len=:), allocatable :: tempstr
  character(len=16) :: fixedlen

  write(0, *) "Print parameter string:"
  call print_str(trim(paramstr))

  write(0, *) "Print trimmed parameter string:"
  call print_str(trim(paramstr))

  write(0, *) "Print inline string:"
  call print_str("fixed")

  fixedlen = "01234567" // c_null_char// "9abcdef"
  write(0, *) "Fixed-length string with embedded null: '"//fixedlen//"'"
  call print_str(fixedlen)

  ! Cut it in half and read it back out to varlen
  tempstr = "Tacocat tacocat!"
  write(0, *) "Halving..."
  tempstr = halved_str(tempstr)

  write(0, *) "Halved: '" // tempstr // "' (len=", len(tempstr), ")"

  tempstr = halved_str(tempstr)
  write(0, *) "Quarter-length string: '"//tempstr//"'"

  write(0, *) "Reversing"
  tempstr = sampletext
  tempstr = reversed_str(tempstr)

  write(0, *) "'"//sampletext//"' -> '"//tempstr//"'"
end program


!-----------------------------------------------------------------------------!
! end of example/runme.f90
!-----------------------------------------------------------------------------!

