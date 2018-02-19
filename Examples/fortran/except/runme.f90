! File : runme.f90
program main
  use except, only : do_it, do_it_again, ierr, get_serr
  use downstream, only : throw_error
  implicit none

  ! Setting bad error flag should throw an exception next, not crash the
  ! program
  !ierr = 1
  write(*,*) "Making bad subroutine call"
  call do_it(-3)

  if (ierr /= 0) then
    write(0,*) "Got error ", ierr, ": ", get_serr()
    ierr = 0
  else
    write(0,*) "Didn't get error!"
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
    write(0,*) "Got error ", ierr, ": ", get_serr()
    ierr = 0
  else
    write(0,*) "Didn't get error!"
    stop 1
  endif
end program
! vim: set ts=2 sw=2 sts=2 tw=129 :
