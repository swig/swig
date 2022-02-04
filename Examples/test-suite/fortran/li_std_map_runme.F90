! File : li_std_map_runme.f90

#include "fassert.h"

program li_std_map_runme
  use ISO_C_BINDING
  implicit none

  call test_map_int_int
  call test_map_string_int
contains

subroutine test_map_int_int
  use ISO_C_BINDING
  ! Note that the test instantiates *multiset* as a set_int
  use li_std_map, only : MapIntInt => IntIntMap
  implicit none
  type(MapIntInt) :: m
  integer :: num_erased
  logical :: inserted = .false.

  m = MapIntInt()
  ASSERT(m%empty())

  call m%insert(10, 4)
  call m%insert(3, 5, inserted)
  ASSERT(inserted .eqv. .true.)
  ASSERT(m%size() == 2)
  ASSERT(m%count(3) == 1)
  ASSERT(m%count(5) == 0)

  ! Insertion of existing element will *not* replace value
  call m%insert(3, 6, inserted)
  ASSERT(inserted .eqv. .false.)
  ASSERT(m%count(3) == 1)
  ASSERT(m%size() == 2)
  ASSERT(m%get(3) == 5)

  ! Use "set" method to unconditionally assign
  call m%set(3, 6)
  ASSERT(m%get(3) == 6)

  call m%erase(10)
  ASSERT(m%size() == 1)
  ASSERT(m%count(10) == 0)

  call m%erase(3, num_erased)
  ASSERT(num_erased == 1)
  ASSERT(m%count(3) == 0)

  call m%release()
end subroutine

subroutine test_map_string_int
  use ISO_C_BINDING
  use li_std_map, only : MapStringInt => StringIntMap
  implicit none
  type(MapStringInt) :: m

  m = MapStringInt()
  ASSERT(m%empty())

  call m%insert("yoohoo", 10)
  call m%insert("howdy", 5)
  ASSERT(m%size() == 2)
  ASSERT(m%count("yoohoo") == 1)
  ASSERT(m%count("hiya") == 0)
  ASSERT(m%get("yoohoo") == 10)
  call m%release()
end subroutine

end program

