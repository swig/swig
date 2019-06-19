! File : array_member_runme.F90

#include "fassert.h"

program array_member_runme
  use array_member
  use ISO_C_BINDING
  implicit none
  type(Foo) :: f
  integer :: i

  f = Foo()
  call f%set_data(get_global_data())

  ! Note that because the C++ declaration is int*, it requires a scalar data pointer, so we pass the first element of the
  ! pointer array (which is 1 in fortran indexing).
  ! In Fortran, loops are inclusive of the range.
  do i = 0, 7
    ASSERT(get_value(f%get_data(), i) == get_value(get_global_data(), i))
  end do

  do i = 0, 7
    call set_value(f%get_data(), i, -i)
  end do

  ! *assign* the data
  call set_global_data(f%get_data())

  ! Now check it
  do i = 0, 7
    ASSERT(get_value(f%get_data(), i) == get_value(get_global_data(), i))
  end do
end program

