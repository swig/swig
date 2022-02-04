! File : li_std_set_runme.f90

#include "fassert.h"

program li_std_set_runme
  use ISO_C_BINDING
  implicit none

  call test_set_string
  call test_multiset_int
contains

subroutine test_multiset_int
  use ISO_C_BINDING
  ! Note that the test instantiates *multiset* as a set_int
  use li_std_set, only : multiset_int => set_int
  implicit none
  type(multiset_int) :: s
  integer :: num_erased

  s = multiset_int()
  ASSERT(s%empty())

  call s%insert(10)
  call s%insert(3)
  ASSERT(s%size() == 2)
  ASSERT(s%count(3) == 1)
  ASSERT(s%count(5) == 0)

  ! Duplicate elements allowed in multiset
  call s%insert(3)
  ASSERT(s%count(3) == 2)
  ASSERT(s%size() == 3)

  call s%erase(10)
  ASSERT(s%size() == 2)
  ASSERT(s%count(10) == 0)

  call s%erase(3, num_erased)
  ASSERT(num_erased == 2)
  ASSERT(s%count(3) == 0)

  call s%insert(1)
  call s%clear()
  ASSERT(s%empty())

  call s%release()
end subroutine

subroutine test_set_string
  use ISO_C_BINDING
  use li_std_set, only : set_string
  implicit none
  type(set_string) :: s
  logical :: inserted = .false.

  s = set_string()
  ASSERT(s%empty())

  call s%insert("yoohoo")
  call s%insert("howdy", inserted)
  ASSERT(inserted .eqv. .true.)
  ASSERT(s%size() == 2)
  ASSERT(s%count("yoohoo") == 1)
  ASSERT(s%count("hiya") == 0)

  call s%insert("howdy", inserted)
  ASSERT(inserted .eqv. .false.)
  ASSERT(s%count("howdy") == 1)
  ASSERT(s%size() == 2)

  call s%erase("yoohoo")
  ASSERT(s%size() == 1)
  ASSERT(s%count("yoohoo") == 0)

  call s%clear()
  ASSERT(s%empty())

  call s%release()
end subroutine

end program

