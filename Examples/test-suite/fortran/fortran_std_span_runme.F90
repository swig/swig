! File : fortran_std_span_runme.F90

#include "fassert.h"

program fortran_std_span_runme
  implicit none

  call test_std_span

contains
subroutine test_std_span
  use fortran_std_span
  use ISO_C_BINDING
  implicit none
  integer(C_INT), dimension(:), pointer :: ptr => null()
  integer(C_INT), dimension(:), pointer :: local_ptr => null()
  integer(C_INT), dimension(3) :: expected = [1, 2, 3]
  integer(C_INT), dimension(:), allocatable, target :: values

  ! Get pointer by value
  ptr => get_by_value()
  ASSERT(associated(ptr) .and. size(ptr) == 3)
  ASSERT(all(ptr == expected))

  ! Get by reference
  ptr => null()
  call get_by_reference(ptr)
  ASSERT(associated(ptr) .and. size(ptr) == 3)
  ASSERT(all(ptr == expected))

  ! Copy from Fortran pointer
  ptr => null()
  allocate(values(4), source = [5, 6, 7, 8])
  local_ptr => values
  call copy(local_ptr, ptr)
  ASSERT(associated(ptr) .and. size(ptr) == 4)
  ASSERT(all(ptr == values))

  ! Copy directly from Fortran array
  ptr => null()
  call copy(values, ptr)
  ASSERT(associated(ptr) .and. size(ptr) == 4)
  ASSERT(all(ptr == values))

  ! Modify values
  ptr => values
  call increment_and_disassociate(ptr)
  ASSERT(values(4) == 9)
  ASSERT(.not. associated(ptr))

  ! Make one pointer point to another
  ptr => null()
  local_ptr => values
  ptr => const_ref(local_ptr)
  ASSERT(associated(ptr, local_ptr))

end subroutine

end program

