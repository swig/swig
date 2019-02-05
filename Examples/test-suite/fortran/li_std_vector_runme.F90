! File : li_std_vector_runme.f90

#include "fassert.h"

program li_std_vector_runme
  use li_std_vector
  use ISO_C_BINDING

  call test_strings
contains
subroutine test_strings
  use arrays
  implicit none
  type(StringVector) :: strings!, reversed

  strings = StringVector()
  call strings%push_back("Sam")
  call strings%push_back("I am")
  ASSERT(strings%front() == "Sam")
  ASSERT(strings%back() == "I am")

  ! XXX The typemaps assume the vector holds POD for views.

!  ! Since RevStringVec takes a string vector by const reference, we must provide it a view. 
!  reversed = RevStringVec(strings%view())
!  ! Note that vectors use Fortran indexing
!  ASSERT(strings%get(1) == "I am")
!  ASSERT(strings%get(2) == "Sam")
end subroutine

end program

