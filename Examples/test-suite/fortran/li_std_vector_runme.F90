! File : li_std_vector_runme.f90

#include "fassert.h"

program li_std_vector_runme
  use li_std_vector
  use ISO_C_BINDING
  implicit none

  call test_bools
  call test_ints
  call test_strings
  call test_structs
contains

subroutine test_bools
  use ISO_C_BINDING
  implicit none
  type(BoolVector) :: v

  v = BoolVector()
  call v%push_back(.true.)
  call v%push_back(.false.)
  call v%push_back(.false.)
  call v%push_back(.true.)
  ASSERT(v%size() == 4)
  ASSERT(v%get(1))
  ASSERT(.not. v%get(2))
  ASSERT(.not. v%get(3))
  ASSERT(v%get(4))

  call v%release()
end subroutine

subroutine test_ints
  use ISO_C_BINDING
  implicit none
  type(IntVector) :: v
  type(IntPtrVector) :: v2
  type(IntConstPtrVector) :: v3
  integer :: i
  integer(C_INT), pointer :: val_ptr

  ! Test that other vectors can be constructed
  v2 = IntPtrVector()
  v3 = IntConstPtrVector()
  call v2%release()
  call v3%release()

  v = IntVector()
  ASSERT(v%empty())
  ASSERT(v%size() == 0)

  call v%push_back(123_c_int)
  ASSERT(.not. v%empty())
  ASSERT(v%size() == 1)
  ASSERT(v%get(1) == 123_c_int)
  val_ptr => v%get_ref(1)
  ASSERT(val_ptr == 123_c_int)
  val_ptr = 999_c_int
  ASSERT(v%get(1) == 999_c_int)

  call v%clear()
  ASSERT(v%empty())

  call v%push_back(123_c_int)
  call v%set(1, 456_c_int)
  ASSERT(v%size() == 1)

  call v%resize(10, -1_c_int)
  do i = 2, 10
    call v%set(i, int(i, c_int))
  end do

  ! remove first element
  call v%erase(1)
  ASSERT(v%size() == 9)
  ASSERT(v%get(1) == 2_c_int)

  ! remove elements 5 through the end 
  call v%erase(5, v%size() + 1)
  ASSERT(v%get(1) == 2_c_int)

  call v%release()
end subroutine

subroutine test_strings
  implicit none
  type(StringVector) :: v, reversed

  v = StringVector()
  call v%push_back("Sam")
  call v%push_back("I am")
  ASSERT(v%front() == "Sam")
  ASSERT(v%back() == "I am")

  reversed = RevStringVec(v)
  ASSERT(reversed%get(1) == "I am")
  ASSERT(reversed%get(2) == "Sam")

  call v%release()
  call reversed%release()
end subroutine

subroutine test_structs
  use ISO_C_BINDING
  implicit none
  type(StructVector) :: v
  type(Struct) :: s

  v = StructVector()
  s = Struct(12.0_c_double)
  call v%push_back(s)
  s = Struct(34.0_c_double)
  call v%push_back(s)
  s = Struct(56.0_c_double)
  call v%push_back(s)
  call s%release()
  ASSERT(v%size() == 3)

  s = v%get(1)
  ASSERT(s%get_num() == 12.0_c_double)
  call s%release()

  s = v%get(2)
  ASSERT(s%get_num() == 34.0_c_double)
  call s%release()

  s = v%get(3)
  ASSERT(s%get_num() == 56.0_c_double)
  call s%release()

  call v%release()
end subroutine
end program

