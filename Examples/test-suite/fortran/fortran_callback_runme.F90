! File : fortran_callback_runme.F90

#include "fassert.h"

module fortran_callback_mod
  use, intrinsic :: ISO_C_BINDING
  use ISO_FORTRAN_ENV
  implicit none
  integer, parameter :: STDOUT = OUTPUT_UNIT
  integer(C_INT), save, public :: module_int
contains

function myexp(left, right) bind(C) &
    result(fresult)
  use, intrinsic :: ISO_C_BINDING
  integer(C_INT), intent(in), value :: left
  integer(C_INT), intent(in), value :: right
  integer(C_INT) :: fresult

  fresult = left ** right
end function
  
function mywrite() bind(C) &
    result(fresult)
  use, intrinsic :: ISO_C_BINDING
  integer(C_INT) :: fresult
  ! write(STDOUT,*) "Hi there"
  fresult = 256_c_int
end function

subroutine store_an_int(i) bind(C)
  use, intrinsic :: ISO_C_BINDING
  integer(C_INT), value, intent(in) :: i
  ! write(STDOUT,*) "Got an integer: ", i
  module_int = i
end subroutine
  
end module

program fortran_callback_runme
  call test_callback
contains

subroutine test_callback
  use fortran_callback
  use fortran_callback_mod
  integer(C_INT) :: i
  procedure(call_binary_cb), pointer :: unused => NULL()
  procedure(binary_op), pointer :: bin_op_ptr => NULL()

  ! Use callbacks with Fortran module pointers
  bin_op_ptr => myexp
  i = call_binary(myexp, 2, 3)
  ASSERT(i == 8)
  i = call_things(mywrite)
  ASSERT(i == 256)
  call also_call_things(store_an_int, 999)
  ASSERT(module_int == 999)

  ! Get a C callback
  bin_op_ptr => get_a_callback("mul")
  ASSERT(associated(bin_op_ptr))
  ASSERT(bin_op_ptr(2, 5) == 10)
  ! Get from the %callback-generated wrapper
  bin_op_ptr => get_mul_cb()
  ASSERT(associated(bin_op_ptr))
  ASSERT(bin_op_ptr(2, 5) == 10)

  bin_op_ptr => get_a_callback("add")
  ASSERT(associated(bin_op_ptr))
  ASSERT(bin_op_ptr(2, 5) == 7)

  bin_op_ptr => get_a_callback("nopenope")
  ASSERT(.not. associated(bin_op_ptr))

end subroutine
end program


