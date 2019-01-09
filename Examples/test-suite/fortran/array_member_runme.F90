! File : array_member_runme.F90

#include "fassert.h"

program array_member_runme
  use array_member
  use ISO_C_BINDING
  implicit none
  type(Foo) :: f
  integer(C_INT), dimension(:), pointer :: global_data, local_data
  integer :: i

  f = Foo()
  global_data => get_global_data()
  call f%set_data(global_data)

  ! Note that because the C++ declaration is int*, it requires a scalar data pointer, so we pass the first element of the
  ! pointer array (which is 1 in fortran indexing).
  local_data => f%get_data()
  ! In Fortran, loops are inclusive of the range.
  do i = 0, 7
    ASSERT(get_value(local_data(1), i) == get_value(global_data(1), i))
  end do

  do i = 0, 7
    call set_value(local_data(1), i, -i)
  end do

  ! *assign* the data
  global_data = f%get_data()

  ! Now check it
  do i = 0, 7
    ASSERT(get_value(local_data(1), i) == get_value(global_data(1), i))
  end do
end program

