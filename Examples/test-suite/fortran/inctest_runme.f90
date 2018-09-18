! File : inctest_runme.f90

program inctest_runme
  use inctest
  use ISO_C_BINDING
  implicit none
  character(kind=C_CHAR, len=:), allocatable :: instr, outstr
  ! If the 'includes' fail, these will produce compiler errors
  type(A) :: ai
  type(B) :: bi

  ai = A()
  call ai%release()

  bi = B()
  call bi%release()
  
  if (importtest1(5) /= 15) stop 1

  ! XXX since importtest2 modifies by reference, we should have to copy it out (so that 'instr' is "white" as well)
  allocate(instr, source="black")
  outstr = importtest2(instr)
  write(*,*) "instr:", instr, " outstr:", outstr
  if (outstr /= "white") stop 1

end program


