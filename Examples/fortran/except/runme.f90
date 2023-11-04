! File : runme.f90
program main
  use example, only : do_it, do_it_again, ierr, get_serr
  use downstream, only : throw_error
  use ISO_FORTRAN_ENV
  implicit none
  integer, parameter :: STDOUT = OUTPUT_UNIT

  ! Setting bad error flag should throw an exception next, not crash the
  ! program
  !ierr = 1
  write(STDOUT,*) "Making bad subroutine call"
  call do_it(-3)

  if (ierr /= 0) then
    write(STDOUT,*) "Got error ", ierr, ": ", get_serr()
    ierr = 0
  else
    write(STDOUT,*) "Didn't get error!"
    stop 1
  endif

  ! Good function call
  call do_it(2)

  ! call do_it(-2)
  ! Uncommenting will produce an error message 
  ! call do_it_again(-3)

  ! Throw an error in a downstream module
  call throw_error()
  if (ierr /= 0) then
    write(STDOUT,*) "Got error ", ierr, ": ", get_serr()
    ierr = 0
  else
    write(STDOUT,*) "Didn't get error!"
    stop 1
  endif
end program

