! File : cpp11_move_typemaps_runme.F90

#include "fassert.h"

program cpp11_move_typemaps_runme
  implicit none

  call test_moveonly
  call test_movecopy
  call test_exception

contains
subroutine test_moveonly
  use cpp11_move_typemaps
  use ISO_C_BINDING
  implicit none
  type(MoveOnly) :: mo
  type(Counter) :: c
  call c%reset_counts()
  mo = MoveOnly(111)
  call c%check_counts(1, 0, 0, 0, 0, 0);
  call mo%take(mo)
  call c%check_counts(1, 0, 0, 1, 0, 2);
  call mo%release()
  call c%check_counts(1, 0, 0, 1, 0, 2);
end subroutine

subroutine test_movecopy
  use cpp11_move_typemaps
  use ISO_C_BINDING
  implicit none
  type(MovableCopyable) :: mc
  type(Counter) :: c
  call c%reset_counts()
  mc = MovableCopyable(111)
  call c%check_counts(1, 0, 0, 0, 0, 0);
  call mc%take(mc)
  call c%check_counts(1, 0, 0, 1, 0, 2);
  call mc%release()
  call c%check_counts(1, 0, 0, 1, 0, 2);
end subroutine

subroutine test_exception
  use cpp11_move_typemaps
  use ISO_C_BINDING
  implicit none
  type(MoveOnly) :: mo
  type(Counter) :: c
  call c%reset_counts()
  mo = MoveOnly(111)
  call mo%take(mo)
  ASSERT(ierr == 0)
  ! Second 'take' should fail
  call mo%take(mo)
  ASSERT(ierr == SWIG_NullReferenceError)
end subroutine
end program

